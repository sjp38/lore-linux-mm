Message-ID: <415A4151.7060301@pobox.com>
Date: Wed, 29 Sep 2004 01:00:01 -0400
From: Jeff Garzik <jgarzik@pobox.com>
MIME-Version: 1.0
Subject: Re: opening a file inside the kernel module
References: <4159E85A.6080806@ammasso.com> <006001c4a5df$ad605c40$8200a8c0@RakeshJagota>
In-Reply-To: <006001c4a5df$ad605c40$8200a8c0@RakeshJagota>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rakesh Jagota <j.rakesh@gdatech.co.in>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

Rakesh Jagota wrote:
> Hi all,
> I am working in linux, i would like to know abt whether can I open a file
> inside the kernel module without using any application. If so how how the
> files_struct will be maintained. Does a kernel module has this struct?

Don't do this.  It's incompatible with namespaces.

Instead, figure out some way to pass the file contents to the kernel module.

	Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
