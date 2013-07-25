Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 87FF66B0034
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 12:02:54 -0400 (EDT)
Received: by mail-vb0-f48.google.com with SMTP id w15so556230vbf.35
        for <linux-mm@kvack.org>; Thu, 25 Jul 2013 09:02:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <51F0D3CA.3080902@parallels.com>
References: <CALCETrXYnkonpBANnUuX+aJ=B=EYFwecZO27yrqcEU8WErz9DA@mail.gmail.com>
 <20130724163734.GE24851@moon> <CALCETrVWgSMrM2ujpO092ZLQa3pWEQM4vdmHhCVUohUUcoR8AQ@mail.gmail.com>
 <20130724171728.GH8508@moon> <1374687373.7382.22.camel@dabdike>
 <CALCETrV5MD1qCQsyz4=t+QW1BJuTBYainewzDfEaXW12S91K=A@mail.gmail.com>
 <20130724181516.GI8508@moon> <CALCETrV5NojErxWOc2RpuYKE0g8FfOmKB31oDz46CRu27hmDBA@mail.gmail.com>
 <20130724185256.GA24365@moon> <51F0232D.6060306@parallels.com>
 <20130724190453.GJ8508@moon> <CALCETrVRQBLrQBL8_Zu0VqBRkDXXr2np57-gt4T59A4jG9jMZw@mail.gmail.com>
 <51F0D3CA.3080902@parallels.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 25 Jul 2013 09:02:32 -0700
Message-ID: <CALCETrVPyHLid246Pw66cCENxM2L75Gm5kUR8fH549W_M1OAWA@mail.gmail.com>
Subject: Re: [PATCH] mm: Save soft-dirty bits on swapped pages
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Thu, Jul 25, 2013 at 12:29 AM, Pavel Emelyanov <xemul@parallels.com> wrote:
> On 07/24/2013 11:40 PM, Andy Lutomirski wrote:
>> On Wed, Jul 24, 2013 at 12:04 PM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
>>> On Wed, Jul 24, 2013 at 10:55:41PM +0400, Pavel Emelyanov wrote:
>>>>>
>
>> Perhaps another bit should be allocated to expose to userspace either
>> "soft-dirty", "soft-clean", or "soft-dirty unsupported"?
>>
>> There's another possible issue with private file-backed pages, though:
>> how do you distinguish clean-and-not-cowed from cowed-but-soft-clean?
>> (The former will reflect changes in the underlying file, I think, but
>> the latter won't.)
>
> There's a bit called PAGE_FILE bit in /proc/pagemap file introduced with
> the 052fb0d635df5d49dfc85687d94e1a87bf09378d commit.
>
> Plz, refer to Documentation/vm/pagemap.txt and soft-dirty.txt, all this
> is described there pretty well.
>

Fair enough.  I'm still a little bit concerned that it will be hard
for userspace to distinguish between things for which soft-dirty works
(which will be more things once the patches are in) and things for
which soft-dirty doesn't work, assuming any are left.  But maybe this
is silly.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
