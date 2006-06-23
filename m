Date: Fri, 23 Jun 2006 15:05:55 -0400
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: linux-mm remailer eats [PATCH xx/yy] subject lines?
Message-ID: <20060623190555.GA14126@kvack.org>
References: <Pine.LNX.4.64.0606221141450.30988@schroedinger.engr.sgi.com> <20060623185828.GB13617@kvack.org> <Pine.LNX.4.64.0606231159310.7339@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0606231159310.7339@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 23, 2006 at 12:00:13PM -0700, Christoph Lameter wrote:
> Have a look at the zoned VM counter patch V6 that was posted recently to 
> linux-mm. The first two patches have the [] intact the later 12 have them 
> all removed.

Looks fine here:

8521     Jun 21 Christoph Lamet ( 113) [PATCH 00/14] Zoned VM counters V5
8522     Jun 21 Christoph Lamet (1184) [PATCH 01/14] Create vmstat.c/.h from pag
8523     Jun 21 Christoph Lamet ( 189) [PATCH 03/14] Convert nr_mapped to per zo
8524     Jun 21 Christoph Lamet ( 575) [PATCH 02/14] Basic ZVC (zoned vm counter
8525     Jun 21 Christoph Lamet ( 279) [PATCH 04/14] Conversion of nr_pagecache
8526     Jun 21 Christoph Lamet ( 145) [PATCH 06/14] Split NR_ANON_PAGES off fro
8527     Jun 21 Christoph Lamet ( 210) [PATCH 14/14] Remove useless struct wbs  
8528     Jun 21 Christoph Lamet ( 206) [PATCH 10/14] Conversion of nr_dirty to p
8529     Jun 21 Christoph Lamet ( 219) [PATCH 12/14] Conversion of nr_unstable t
8530     Jun 21 Christoph Lamet ( 110) [PATCH 13/14] Conversion of nr_bounce to
8531     Jun 21 Christoph Lamet ( 129) [PATCH 08/14] Conversion of nr_slab to pe
8532     Jun 21 Christoph Lamet ( 154) [PATCH 07/14] zone_reclaim: remove /proc/
8533     Jun 21 Christoph Lamet (  60) [PATCH 05/14] Remove NR_FILE_MAPPED from
8534     Jun 21 Christoph Lamet ( 166) [PATCH 11/14] Conversion of nr_writeback
8535     Jun 21 Christoph Lamet ( 162) [PATCH 09/14] Conversion of nr_pagetables

That said, your mails have two Subject: lines in them, which is how kvack.org 
is receiving them from you.  ie:

		-ben

Date:   Thu, 22 Jun 2006 09:40:15 -0700 (PDT)
From:   Christoph Lameter <clameter@sgi.com>
To:     akpm@osdl.org
Cc:     linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
Message-Id: <20060622164015.28809.27246.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060622164004.28809.8446.sendpatchset@schroedinger.engr.sgi.com>
References: <20060622164004.28809.8446.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 02/14] Basic ZVC (zoned vm counter) implementation
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=0.93.5
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
Subject: zoned vm counters: per zone counter functionality
From:   Christoph Lameter <clameter@sgi.com>
Return-Path: <owner-linux-mm@kvack.org>
X-Envelope-To: <"|/home/majordomo/wrapper archive -f /home/ftp/pub/archives/linu
x-mm/linux-mm -m -a"> (uid 0)
X-Orcpt: rfc822;linux-mm-outgoing
Original-Recipient: rfc822;linux-mm-outgoing


		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
