Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 7E37A6B005D
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 10:05:03 -0500 (EST)
Received: by mail-oa0-f41.google.com with SMTP id k14so7586908oag.14
        for <linux-mm@kvack.org>; Tue, 20 Nov 2012 07:05:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121120145807.GB19467@localhost>
References: <CAGTBQpaDR4+V5b1AwAVyuVLu5rkU=Wc1WeUdLu5ag=WOk5oJzQ@mail.gmail.com>
	<20121120080427.GA11019@localhost>
	<CAGTBQpayd-HyH8SWfUCavS7epybcQR5SAx+tr+wyB38__4b-2Q@mail.gmail.com>
	<20121120145807.GB19467@localhost>
Date: Tue, 20 Nov 2012 12:05:02 -0300
Message-ID: <CAGTBQpY-yav5G4aPSBdUmACWQbe8RR=8OnRwKHbMuuR=GBgBxw@mail.gmail.com>
Subject: Re: fadvise interferes with readahead
From: Claudio Freire <klaussfreire@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

On Tue, Nov 20, 2012 at 11:58 AM, Fengguang Wu <fengguang.wu@intel.com> wrote:
>
>> But if cache hits were to simply update
>> readahead state, it would only mean that read calls behave the same
>> regardless of fadvise calls. I think that's worth pursuing.
>
> Here you are describing an alternative solution that will somehow trap
> into the readahead code even when, for example, the application is
> accessing once and again an already cached file?  I'm afraid this will
> add non-trivial overheads and is less attractive than the "readahead
> on fadvise" solution.

Not for all cache hits, only those in state !PageUptodate, which are
I/O in progress, the case that hurts.

>> I ought to try to prepare a patch for this to illustrate my point. Not
>> sure I'll be able to though.
>
> I'd be glad to materialize the readahead on fadvise proposal, if there
> are no obvious negative examples/cases.

I don't expect a significant performance hit if only !PageUptodate
hits invoke readahead code. But I'm no kernel expert either.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
