Return-Path: <owner-linux-mm@kvack.org>
Message-id: <1376387202.31048.2.camel@AMDC1943>
Subject: Re: [RFC 0/3] Pin page control subsystem
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Date: Tue, 13 Aug 2013 11:46:42 +0200
In-reply-to: <1376377502-28207-1-git-send-email-minchan@kernel.org>
References: <1376377502-28207-1-git-send-email-minchan@kernel.org>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
MIME-version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, guz.fnst@cn.fujitsu.com, Benjamin LaHaise <bcrl@kvack.org>, Dave Hansen <dave.hansen@intel.com>, lliubbo@gmail.com, aquini@redhat.com, Rik van Riel <riel@redhat.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>

Hi Minchan,

On wto, 2013-08-13 at 16:04 +0900, Minchan Kim wrote:
> patch 2 introduce pinpage control
> subsystem. So, subsystems want to control pinpage should implement own
> pinpage_xxx functions because each subsystem would have other character
> so what kinds of data structure for managing pinpage information depends
> on them. Otherwise, they can use general functions defined in pinpage
> subsystem. patch 3 hacks migration.c so that migration is
> aware of pinpage now and migrate them with pinpage subsystem.

I wonder why don't we use page->mapping and a_ops? Is there any
disadvantage of such mapping/a_ops?

Best regards,
Krzysztof

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
