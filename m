Date: Mon, 14 Oct 2002 17:43:00 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [rfc][patch] Memory Binding API v0.3 2.5.41
Message-ID: <2005946728.1034617377@[10.10.2.3]>
In-Reply-To: <3DAB6385.9000207@us.ibm.com>
References: <3DAB6385.9000207@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: colpatch@us.ibm.com
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, LSE <lse-tech@lists.sourceforge.net>, Andrew Morton <akpm@zip.com.au>, Michael Hohnbaum <hohnbaum@us.ibm.com>
List-ID: <linux-mm.kvack.org>

>>>> 4) An ordered zone list is probably the more natural mapping.
>>> 
>>> See my comments above about per zone/memblk.  And you reemphasize my point, how do we order the zone lists in such a way that a user of the API can easily know/find out what zone #5 is?
>> Could you explain how that problem is different from finding out
>> what memblk #5 is ... I don't see the difference?
> Errm...  __memblk_to_node(5)

As opposed to creating __zone_to_node(5) ?
 
> I"m not saying that we couldn't add a similar interface for zones... something along the lines of:
> 	__memblk_and_zone_to_flat_zone_number(5, DMA)
> or some such.  It just isn't there now...

Surely this would dispose of the need for memblks? If not, then
I'd agree it's probably just adding more complication.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
