Date: Tue, 8 Jul 2003 15:07:30 +0200
From: Petr Vandrovec <vandrove@vc.cvut.cz>
Subject: Re: 2.5.74-mm2 + nvidia (and others)
Message-ID: <20030708130729.GA12219@vana.vc.cvut.cz>
References: <6A3BC5C5B2D@vcnet.vc.cvut.cz> <1057669356.6858.29.camel@sm-wks1.lan.irkk.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1057669356.6858.29.camel@sm-wks1.lan.irkk.nu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Axelsson <smiler@lanil.mine.nu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 08, 2003 at 03:02:37PM +0200, Christian Axelsson wrote:
> On Tue, 2003-07-08 at 14:37, Petr Vandrovec wrote:
> > 
> > Either copy compat_pgtable.h from vmmon to vmnet, or grab
> > vmware-any-any-update36. I forgot to update vmnet's copy of this file.
> 
> Still getting same errors. However if I copy pgtbl.h from vmmon it
> compiles. vmmon uses pmd_offset_map instead of pmd_offset

Yes, I know :-( I forgot that I modified pgtbl.h too. All these files are 
common to vmmon/vmnet and should be same. update36 large 173887 bytes
should have all needed files updated in vmnet too. If it will not work,
I'll download -mm2 and try really building code, as apparently even
trivial changes are too complicated for me today.
							Petr Vandrovec

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
