Date: Tue, 22 Apr 2003 14:04:19 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: objrmap and vmtruncate
Message-ID: <20030422140419.F2944@redhat.com>
References: <20030422165746.GK23320@dualathlon.random> <Pine.LNX.4.44.0304221324380.24424-100000@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0304221324380.24424-100000@devserv.devel.redhat.com>; from mingo@redhat.com on Tue, Apr 22, 2003 at 01:34:46PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 22, 2003 at 01:34:46PM -0400, Ingo Molnar wrote:
> is anything forcing us to fixing up mappings during a truncate? What we
> need is just for the FS to recognize pages behind end-of-inode to still
> potentially exist after truncation, if those areas were mapped before the
> truncation. Apps that do not keep uptodate with truncaters can get
> out-of-date data anyway, via read()/write() anyway. Are there good
> arguments to be this strict across truncate()? We sure could make it safe
> even thought it's not safe currently.

Yes: access beyond EOF is required to SIGBUS according to various 
standards.  But keep in mind that this is a slow path and doesn't have to 
be anywhere near optimal, unlike page reclaim.

		-ben
-- 
Junk email?  <a href="mailto:aart@kvack.org">aart@kvack.org</a>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
