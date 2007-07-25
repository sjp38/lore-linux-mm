Received: by wa-out-1112.google.com with SMTP id m33so402750wag
        for <linux-mm@kvack.org>; Wed, 25 Jul 2007 15:28:46 -0700 (PDT)
Message-ID: <b14e81f00707251528i275b0f6by235acce2d5b83473@mail.gmail.com>
Date: Wed, 25 Jul 2007 18:28:46 -0400
From: "Michael Chang" <thenewme91@gmail.com>
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
In-Reply-To: <20070725150509.4d80a85e.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <46A58B49.3050508@yahoo.com.au> <46A6D7D2.4050708@gmail.com>
	 <Pine.LNX.4.64.0707242211210.2229@asgard.lang.hm>
	 <46A6DFFD.9030202@gmail.com>
	 <30701.1185347660@turing-police.cc.vt.edu> <46A7074B.50608@gmail.com>
	 <20070725082822.GA13098@elte.hu> <46A70D37.3060005@gmail.com>
	 <20070725113401.GA23341@elte.hu> <20070725150509.4d80a85e.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Ingo Molnar <mingo@elte.hu>, david@lang.hm, nickpiggin@yahoo.com.au, Valdis.Kletnieks@vt.edu, ray-lk@madrabbit.org, jesper.juhl@gmail.com, linux-kernel@vger.kernel.org, ck@vds.kolivas.org, linux-mm@kvack.org, akpm@linux-foundation.org, rene.herman@gmail.com
List-ID: <linux-mm.kvack.org>

On 7/25/07, Paul Jackson <pj@sgi.com> wrote:
> Question:
>   Could those who have found this prefetch helps them alot say how
>   many disks they have?  In particular, is their swap on the same
>   disk spindle as their root and user files?

I have found that swap prefetch helped on all of the four machines
machine I have, although the effect is more noticeable on machines
with slower disks. They all have one hard disk, and root and swap were
always on the same disk. I have no idea how to determine how many disk
spindles they have, but since the drives are mainly low-end consumer
models sold with low-end sub $500 PCs...

-- 
Michael Chang

Please avoid sending me Word or PowerPoint attachments. Send me ODT,
RTF, or HTML instead.
See http://www.gnu.org/philosophy/no-word-attachments.html
Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
