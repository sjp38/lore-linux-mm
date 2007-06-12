Date: Mon, 11 Jun 2007 21:14:36 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
Message-ID: <20070612041436.GC11781@holomorphy.com>
References: <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com> <20070611225213.GB14458@us.ibm.com> <20070611230829.GC14458@us.ibm.com> <20070611231008.GD14458@us.ibm.com> <Pine.LNX.4.64.0706111615450.23857@schroedinger.engr.sgi.com> <20070612001542.GJ14458@us.ibm.com> <20070612034407.GB11773@holomorphy.com> <Pine.LNX.4.64.0706112050070.25900@schroedinger.engr.sgi.com> <20070612035324.GB11781@holomorphy.com> <Pine.LNX.4.64.0706112053190.25967@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706112053190.25967@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 11, 2007 at 08:50:49PM -0700, Christoph Lameter wrote:
>>> Each task already has a next node field. Just use that.

On Mon, 11 Jun 2007, William Lee Irwin III wrote:
>> That's new. It sounds convenient.

On Mon, Jun 11, 2007 at 08:53:31PM -0700, Christoph Lameter wrote:
> No its ancient.

Heh. It all depends on your view of time. One's point of view tends
toward geologic when 2.4.9 (not a typo) is still current for a number
of one's customers. Not to mention when one maintains code (or attempts
to, however poorly) with open bugs where the last known working
versions are in the 2.0.x and 2.2.x version spaces.

Shiny new code from 2005 can indeed be a breath of fresh air to some.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
