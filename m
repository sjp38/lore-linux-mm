Subject: Re: 2.5.69-mm2 Kernel panic, possibly network related
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <3EB8DBA0.7020305@aitel.hist.no>
References: <20030506232326.7e7237ac.akpm@digeo.com>
	 <3EB8DBA0.7020305@aitel.hist.no>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Message-Id: <1052304024.9817.3.camel@rth.ninka.net>
Mime-Version: 1.0
Date: 07 May 2003 03:40:24 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Helge Hafting <helgehaf@aitel.hist.no>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2003-05-07 at 03:10, Helge Hafting wrote:
> 2.5.69-mm1 is fine, 2.5.69-mm2 panics after a while even under very
> light load.

Do you have AF_UNIX built modular?

-- 
David S. Miller <davem@redhat.com>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
