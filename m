Subject: Re: broken VM in 2.4.10-pre9
Date: Wed, 19 Sep 2001 23:30:41 +0100 (BST)
In-Reply-To: <878A2048A35CD141AD5FC92C6B776E4907B7A5@xchgind02.nsisw.com> from "Rob Fuller" at Sep 19, 2001 05:15:21 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E15jprd-00042O-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rob Fuller <rfuller@nsisoftware.com>
Cc: "David S. Miller" <davem@redhat.com>, ebiederm@xmission.com, alan@lxorguk.ukuu.org.uk, phillips@bonn-fries.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> "One argument for reverse mappings is distributed shared memory or
> distributed file systems and their interaction with memory mapped files.
> For example, a distributed file system may need to invalidate a specific
> page of a file that may be mapped multiple times on a node."

Wouldn't it be better for the file system itself to be doing that work. Also
do real world file systems that actually perform usably do this or just zap
the cached mappings like OpenGFS does.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
