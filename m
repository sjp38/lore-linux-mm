Date: Wed, 11 Jun 2003 22:31:42 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.70-mm8
Message-Id: <20030611223142.0e5ac956.akpm@digeo.com>
In-Reply-To: <3EE80D89.6020805@sbcglobal.net>
References: <20030611013325.355a6184.akpm@digeo.com>
	<3EE80D89.6020805@sbcglobal.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jordan Breeding <jordan.breeding@sbcglobal.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jordan Breeding <jordan.breeding@sbcglobal.net> wrote:
>
>  Then I tried backing out pci-init-ordering-fix.patch and 
>  that did the trick.

Yeah, that experiment will be terminated.  It fixed two machines and broke
three.


>  when will the elevator selection messages either go 
>  away or get limited to a couple of times per boot.

umm, in about five minutes time?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
