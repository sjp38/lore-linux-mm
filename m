Subject: Re: 2.5.74-mm2 + nvidia (and others)
From: Flameeyes <dgp85@users.sourceforge.net>
In-Reply-To: <6A3BC5C5B2D@vcnet.vc.cvut.cz>
References: <6A3BC5C5B2D@vcnet.vc.cvut.cz>
Content-Type: text/plain
Message-Id: <1057669044.918.1.camel@laurelin>
Mime-Version: 1.0
Date: 08 Jul 2003 14:57:25 +0200
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2003-07-08 at 14:37, Petr Vandrovec wrote:
> Either copy compat_pgtable.h from vmmon to vmnet, or grab
> vmware-any-any-update36. I forgot to update vmnet's copy of this file.
also vmware-any-any-update36 doesn't work... works only if we copy also
pgtbl.h from vmmon to vmnet.
-- 
Flameeyes <dgp85@users.sf.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
