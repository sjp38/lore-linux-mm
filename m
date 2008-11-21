Date: Fri, 21 Nov 2008 10:29:09 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: linux memory mgmt system question
In-Reply-To: <396532.97722.qm@web56504.mail.re3.yahoo.com>
Message-ID: <Pine.LNX.4.64.0811211027210.26758@quilx.com>
References: <396532.97722.qm@web56504.mail.re3.yahoo.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Catalin CIONTU <cciontu@yahoo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The numbers returned by free are numbers that describe the state of the
memory for the OS. The OS can increase the amount of free memory at
any time by reclaiming memory from the disk cache, processes and other
operating system structures.

Why do you need these numbers?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
