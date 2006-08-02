Subject: Regression in 2.6.18-rc2-mm1:  mbind() not binding
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Wed, 02 Aug 2006 12:06:41 -0400
Message-Id: <1154534801.5145.69.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Just a heads up:  it appears that mbind() does not work--e.g. on
anonymous pages--in 2.6.18-rc2-mm1.

Found with my memtoy tool, available at:
	http://free.linux.hp.com/~lts/Tools/memtoy-latest.tar.gz

Requires a NUMA platform or fakenuma kernel to see this.  I'm not sure
yet whether the specified policy is not being installed, or it's just
being ignored at allocation time.  Note that default policy works:  when
I change the cpu/node affinity of the test, allocation tracks to new
node.  This indicates that get_mempolicy(...,  MPOL_F_NODE|MPOL_F_ADDR)
isn't lying to me.

Works in 2.6.18-rc2.  I've just grabbed the broken out series, and will
attempt to isolate the patch.  If anyone else has come across this and
already knows what's causing it--that would save me some effort.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
