Message-ID: <4173E176.4050102@shadowen.org>
Date: Mon, 18 Oct 2004 16:29:58 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] CONFIG_NONLINEAR for small systems
References: <4173D219.3010706@shadowen.org> <20041019.001709.41629797.taka@valinux.co.jp>
In-Reply-To: <20041019.001709.41629797.taka@valinux.co.jp>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hirokazu Takahashi wrote:

> What version of kernel are you using?
> I recommend linux-2.6.9-rc4-mm1 for your purpose, as it has eliminated
> bitmaps for free pages to simplify managing buddy allocator.
> This may help you.

Doh, 2.6.9-rc4.  It was the removal of the bitmaps which stopped me 
porting to there.  I didn't want to do the extra work until it was 
decided if they are going for good :).

-apw
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
