Date: Thu, 4 Dec 2003 10:27:30 -0800
Subject: Re: memory hotremove prototype, take 3
Message-ID: <20031204182729.GA7965@sgi.com>
References: <20031201034155.11B387007A@sv1.valinux.co.jp> <187360000.1070480461@flay> <20031204035842.72C9A7007A@sv1.valinux.co.jp> <152440000.1070516333@10.10.2.4> <20031204154406.7FC587007A@sv1.valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20031204154406.7FC587007A@sv1.valinux.co.jp>
From: jbarnes@sgi.com (Jesse Barnes)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 05, 2003 at 12:44:06AM +0900, IWAMOTO Toshihiro wrote:
> IIRC, memory is contiguous within a NUMA node.  I think Goto-san will
> clarify this issue when his code gets ready. :-)

Not on all systems.  On sn2 we use ia64's virtual memmap to make memory
within a node appear contiguous, even though it may not be.

Jesse
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
