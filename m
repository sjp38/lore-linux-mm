From: Chase Venters <chase.venters@clientec.com>
Subject: Re: Commenting out out_of_memory() function in __alloc_pages()
Date: Sun, 9 Jul 2006 02:55:10 -0500
References: <BKEKJNIHLJDCFGDBOHGMGEEJDCAA.abum@aftek.com>
In-Reply-To: <BKEKJNIHLJDCFGDBOHGMGEEJDCAA.abum@aftek.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200607090255.34452.chase.venters@clientec.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Abu M. Muttalib" <abum@aftek.com>
Cc: Robert Hancock <hancockr@shaw.ca>, kernelnewbies@nl.linux.org, linux-newbie@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sunday 09 July 2006 01:10, Abu M. Muttalib wrote:
> I have a total of 16 MB RAM. My main concern is that I was running the same
> set of applications earlier on linux-2.4.19-rmk7-pxa1 and didn't get any
> out of memory. I am running the same application and get the OOM, though
> the appearance is not uniform, at times it comes on a freshly booted system
> and at times it didn't come when the system is on overnight.... Why I am
> getting here??? Is there any problem with linux-2.6.13?

I'm just guessing now, but it's possible that the default thresholds have 
changed from 2.4.19 to 2.6.13 (indeed, the amount of progress between those 
two versions is more than some OS kernels have seen in their lifetime).

You might look at Documentation/sysctl/vm.txt and check those settings on 
2.4.19 versus 2.6.13.

What application are you having trouble with?

> I have tried to check the application for memory leak with no success.
> There seems to be no memory leak.
>
> >Thanks,
> >Chase
>
> Regards,
> Abu.

Thanks,
Chase

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
