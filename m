Date: Fri, 21 Jun 2002 18:17:32 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: HighMem test
Message-ID: <20020621181732.J1499@redhat.com>
References: <20020621220053.26673.qmail@email.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20020621220053.26673.qmail@email.com>; from agsanjay@email.com on Sat, Jun 22, 2002 at 06:00:53AM +0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sanjay AG <agsanjay@email.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

That was fixed in 2.4.19-rc1.

		-ben

On Sat, Jun 22, 2002 at 06:00:53AM +0800, Sanjay AG wrote:
> Hi,
>    I am trying to test a ethernet driver that supports 64-bit addressing. I was hoping that I would see buffers which are mapped beyond the 4G physical addr (i.e > 32-bit) if I have HIGHMEM enabled and use apps that make use of "sendfile" for Zero-copy (like in pure-ftpd) on a IA-32 machine. However my pci_map_page for the buffer seems to have the upper-32 bits all 0's. Is there something I am missing w/regard to HighMem operation? or is there a better test app that I can use?
> 
>  BTW my test machine setup has 5GB of RAM running a 2.4.16 HIGHMEM enabled kernel. 
> 
> Would appreciate any responses or pointers...
> -Sanjay
> -- 
> __________________________________________________________
> Sign-up for your own FREE Personalized E-mail at Mail.com
> http://www.mail.com/?sr=signup
> 
> Save up to $160 by signing up for NetZero Platinum Internet service.
> http://www.netzero.net/?refcd=N2P0602NEP8
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/

-- 
"You will be reincarnated as a toad; and you will be much happier."
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
