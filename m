Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 606366B004D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 11:26:48 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id EC1B582C4F0
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 11:33:11 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 3zKbPHf5vovq for <linux-mm@kvack.org>;
	Mon,  2 Nov 2009 11:33:07 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8BBF882C89F
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 11:32:06 -0500 (EST)
Date: Mon, 2 Nov 2009 11:24:48 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 1/1] MM: slqb, fix per_cpu access
In-Reply-To: <1257151763-11507-1-git-send-email-jirislaby@gmail.com>
Message-ID: <alpine.DEB.1.10.0911021124380.24535@V090114053VZO-1>
References: <4AEE5EA2.6010905@kernel.org> <1257151763-11507-1-git-send-email-jirislaby@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Jiri Slaby <jirislaby@gmail.com>
Cc: npiggin@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>


Reviewed-by: Christoph Lameter <cl@linux-foundation.org>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
