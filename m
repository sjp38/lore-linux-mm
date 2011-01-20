Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 30F728D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 08:16:03 -0500 (EST)
Received: by ywj3 with SMTP id 3so174808ywj.14
        for <linux-mm@kvack.org>; Thu, 20 Jan 2011 05:16:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110120124730.GA7284@infradead.org>
References: <9e7aa896-ed1f-4d50-8227-3a922be39949@default>
	<4D382B99.7070005@vflare.org>
	<20110120124730.GA7284@infradead.org>
Date: Thu, 20 Jan 2011 15:16:00 +0200
Message-ID: <AANLkTim4t4zT5W0TJ7Vwzb568u1W6vz3b_cZirfK0Uhs@mail.gmail.com>
Subject: Re: [PATCH 0/8] zcache: page cache compression support
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Pekka Enberg <penberg@cs.helsinki.fi>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On Thu, Jan 20, 2011 at 07:33:29AM -0500, Nitin Gupta wrote:
>> I just started looking into kztmem (weird name!) but on
>> the high level it seems so much similar to zcache with some
>> dynamic resizing added (callback for shrinker interface).
>>
>> Now, I'll try rebuilding zcache according to new cleancache
>> API as provided by these set of patches. This will help refresh
>> whatever issues I was having back then with pagecache
>> compression and maybe pick useful bits/directions from
>> new kztmem work.

On Thu, Jan 20, 2011 at 2:47 PM, Christoph Hellwig <hch@infradead.org> wrot=
e:
> Yes, we shouldn't have two drivers doing almost the same in the
> tree. =A0Also adding core hooks for staging drivers really is against
> the idea of staging of having a separate crap tree. =A0So it would be
> good to get zcache into a state where we can merge it into the
> proper tree first. =A0And then we can discuss if adding an abstraction
> layer between it and the core VM really makes sense, and if it does
> how. =A0 But I'm pretty sure there's now need for multiple layers of
> abstraction for something that's relatively core VM functionality.
>
> E.g. the abstraction should involve because of it's users, not the
> compressed caching code should involve because it's needed to present
> a user for otherwise useless code.

I'm not sure which hooks you're referring to but for zcache we did this:

http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3Dcomm=
itdiff;h=3Db3a27d0529c6e5206f1b60f60263e3ecfd0d77cb

I completely agree with getting zcache merged properly before going
for the cleancache stuff.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
