Date: Wed, 02 Oct 2002 15:02:56 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [RFC][PATCH]  4KB stack + irq stack for x86
Message-ID: <388830000.1033596176@flay>
In-Reply-To: <20021002215649.GY3000@clusterfs.com>
References: <3D9B62AC.30607@us.ibm.com> <20021002215649.GY3000@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andreas Dilger <adilger@clusterfs.com>, Dave Hansen <haveblue@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I'm a little bit worried about this patch.  Have you tried something
> like NFS-over-ext3-over-LVM-over-MD or so, which can have a deep stack?

No, I don't think we're that twisted. 
But feel free ... and have fun getting LVM to work first ;-)

IMHO, bugfixing arcane corner-case bloat issues can come later, if all normal
configs work.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
