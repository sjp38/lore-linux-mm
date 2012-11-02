Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id C1D266B0044
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 19:27:48 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id t2so1966890qcq.14
        for <linux-mm@kvack.org>; Fri, 02 Nov 2012 16:27:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121102225341.GC2070@barrios>
References: <CAA25o9SD8cZUaVT-SA2f9NVvPdmYo++WGn8Gfie3bhkrc8dCxQ@mail.gmail.com>
	<20121102225341.GC2070@barrios>
Date: Fri, 2 Nov 2012 16:27:47 -0700
Message-ID: <CAA25o9SXNHFgQmVMNmGNwPDCRpRTsRDW8oRvnLyofGrVo6bnNQ@mail.gmail.com>
Subject: Re: zram on ARM
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>

On Fri, Nov 2, 2012 at 3:53 PM, Minchan Kim <minchan@kernel.org> wrote:
> Hi Luigi,
>
> I am embarrassed because recently I have tried to promote zram
> from staging tree.
>
> I thought it's very stable because our production team already have
> used recent zram on ARM and they don't report any problem to me until now.
> But I'm not sure how they use it stressfully so I will check it.
> And other many project of android have used it but I doubt it's recent zram
> so it would be a problem of recent patch.
>
> Anyway I will look at it but unfortunately, as I said earlier, I should go
> to training course during 2 weeks. So reply will be late.
> I hope other people involve in during that.
>
> Thanks for the reporting.

No, it is I who should be embarrassed because my results were
premature and I jumped the gun.  The backport of ToT to 3.4 didn't
work correctly, even if it compiled.  I was getting OOPSes in zram
data transfers on x86---never mind ARM.

I am now trying a safer approach, by just applying the patch that
removes the x86 dependency.  I have tested that change on x86 and it
works fine (perhaps a bit more sluggish?  Could be subjective).  I am
still working on getting the ARM side properly tested.

Thank you and I hope your training goes well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
