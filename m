Date: Thu, 07 Oct 2004 10:56:43 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH]  no buddy bitmap patch : intro and includes [0/2]
Message-ID: <1343960000.1097171803@[10.10.2.4]>
In-Reply-To: <1097165419.3625.54.camel@localhost>
References: <D36CE1FCEFD3524B81CA12C6FE5BCAB007ED31D6@fmsmsx406.amr.corp.intel.com> <1097163578.3625.43.camel@localhost>  <1260090000.1097164623@[10.10.2.4]> <1097165419.3625.54.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Matthew E Tolentino <matthew.e.tolentino@intel.com>, Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>, Andrew Morton <akpm@osdl.org>, William Lee Irwin III <wli@holomorphy.com>, "Luck, Tony" <tony.luck@intel.com>, Hirokazu Takahashi <taka@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

>> Makese sense on both counts. Would be nice to add the justification to 
>> the changelog ;-)
> 
> Would you mind running these through your normal set of tests on the
> NUMAQ?  The last time I ran them, I didn't see a performance impact
> either way, and I'd be good to check again.

Makes no difference in performance that I can see.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
