Return-Path: <owner-linux-mm@kvack.org>
Date: Tue, 13 Aug 2013 10:23:38 -0400
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [RFC 0/3] Pin page control subsystem
Message-ID: <20130813142338.GD13330@kvack.org>
References: <1376377502-28207-1-git-send-email-minchan@kernel.org> <1376387202.31048.2.camel@AMDC1943>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1376387202.31048.2.camel@AMDC1943>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, guz.fnst@cn.fujitsu.com, Dave Hansen <dave.hansen@intel.com>, lliubbo@gmail.com, aquini@redhat.com, Rik van Riel <riel@redhat.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>

On Tue, Aug 13, 2013 at 11:46:42AM +0200, Krzysztof Kozlowski wrote:
> Hi Minchan,
> 
> On wto, 2013-08-13 at 16:04 +0900, Minchan Kim wrote:
> > patch 2 introduce pinpage control
> > subsystem. So, subsystems want to control pinpage should implement own
> > pinpage_xxx functions because each subsystem would have other character
> > so what kinds of data structure for managing pinpage information depends
> > on them. Otherwise, they can use general functions defined in pinpage
> > subsystem. patch 3 hacks migration.c so that migration is
> > aware of pinpage now and migrate them with pinpage subsystem.
> 
> I wonder why don't we use page->mapping and a_ops? Is there any
> disadvantage of such mapping/a_ops?

That's what the pending aio patches do, and I think this is a better 
approach for those use-cases that the technique works for.

The biggest problem I see with the pinpage approach is that it's based on a
single page at a time.  I'd venture a guess that many pinned pages are done 
in groups of pages, not single ones.

		-ben

> Best regards,
> Krzysztof

-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
