Date: Thu, 04 Dec 2003 10:29:53 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: memory hotremove prototype, take 3
Message-ID: <14880000.1070562593@flay>
In-Reply-To: <20031204182729.GA7965@sgi.com>
References: <20031201034155.11B387007A@sv1.valinux.co.jp> <187360000.1070480461@flay> <20031204035842.72C9A7007A@sv1.valinux.co.jp> <152440000.1070516333@10.10.2.4> <20031204154406.7FC587007A@sv1.valinux.co.jp> <20031204182729.GA7965@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jesse Barnes <jbarnes@sgi.com>, IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> IIRC, memory is contiguous within a NUMA node.  I think Goto-san will
>> clarify this issue when his code gets ready. :-)
> 
> Not on all systems.  On sn2 we use ia64's virtual memmap to make memory
> within a node appear contiguous, even though it may not be.

Wasn't there a plan to get rid of that though? I forget what it was,
probably using CONFIG_NONLINEAR too ... ?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
