Received: by wx-out-0102.google.com with SMTP id t13so418867wxc
        for <linux-mm@kvack.org>; Fri, 16 Jun 2006 04:20:22 -0700 (PDT)
Message-ID: <84144f020606160420n5e1c16f3s94c4d47551be0fff@mail.gmail.com>
Date: Fri, 16 Jun 2006 14:20:21 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: Memory Leak Detection and Kernel Memory monitoring tool
In-Reply-To: <05B7784238A51247A0A9FB4B348CECAE01D7686A@PNE-HJN-MBX01.wipro.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <AcaRI8wQZTxlnEvkSZKzcK/VjpZN+AACMtwA>
	 <05B7784238A51247A0A9FB4B348CECAE01D7686A@PNE-HJN-MBX01.wipro.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "kaustav.majumdar@wipro.com" <kaustav.majumdar@wipro.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/16/06, kaustav.majumdar@wipro.com <kaustav.majumdar@wipro.com> wrote:
> Please suggest other feasible ways of detecting leaks and monitoring kernel memory
> utilization.

Well, there's CONFIG_DEBUG_SLAB_LEAK starting with 2.6.16, I think.

                                            Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
