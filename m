Date: Fri, 11 Jul 2003 18:21:30 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.74-mm2 + nvidia (and others)
Message-ID: <20030712012130.GB15452@holomorphy.com>
References: <1057590519.12447.6.camel@sm-wks1.lan.irkk.nu> <200307071734.01575.schlicht@uni-mannheim.de> <20030707123012.47238055.akpm@osdl.org> <1057647818.5489.385.camel@workshop.saharacpt.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1057647818.5489.385.camel@workshop.saharacpt.lan>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schlemmer <azarah@gentoo.org>
Cc: Andrew Morton <akpm@osdl.org>, Thomas Schlichter <schlicht@uni-mannheim.de>, smiler@lanil.mine.nu, KML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 08, 2003 at 09:03:39AM +0200, Martin Schlemmer wrote:
> +#if defined(NV_PMD_OFFSET_UNMAP)
> +    pmd_unmap(pg_mid_dir);
> +#endif

You could try defining an NV_PMD_OFFSET_UNMAP() which is a nop for
mainline and DTRT for -mm.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
