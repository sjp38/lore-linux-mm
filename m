Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Subject: RE: [Lhms-devel] Re: [PATCH]  no buddy bitmap patch : intro and includes [0/2]
Date: Thu, 7 Oct 2004 08:03:22 -0700
Message-ID: <D36CE1FCEFD3524B81CA12C6FE5BCAB007ED31D6@fmsmsx406.amr.corp.intel.com>
From: "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>, Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, LHMS <lhms-devel@lists.sourceforge.net>, Andrew Morton <akpm@osdl.org>, William Lee Irwin III <wli@holomorphy.com>, "Luck, Tony" <tony.luck@intel.com>, Dave Hansen <haveblue@us.ibm.com>, Hirokazu Takahashi <taka@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

>> Followings are patches for removing bitmaps from buddy 
>allocator, against 2.6.9-rc3.
>> I think this version is much clearer than ones I posted a month ago.
>...
>> If there is unclear point, please tell me.
>
>What was the purpose behind this, again? Sorry, has been too long since
>I last looked.
>

For one, it avoids the otherwise requisite resizing of the bitmaps 
during memory hotplug operations...

matt
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
