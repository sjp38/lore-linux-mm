Date: Mon, 14 Oct 2002 17:20:27 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [rfc][patch] Memory Binding API v0.3 2.5.41
Message-ID: <2004595005.1034616026@[10.10.2.3]>
In-Reply-To: <3DAB5DF2.5000002@us.ibm.com>
References: <3DAB5DF2.5000002@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: colpatch@us.ibm.com, "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, LSE <lse-tech@lists.sourceforge.net>, Andrew Morton <akpm@zip.com.au>, Michael Hohnbaum <hohnbaum@us.ibm.com>
List-ID: <linux-mm.kvack.org>

 
>> 4) An ordered zone list is probably the more natural mapping.
> See my comments above about per zone/memblk.  And you reemphasize my point, how do we order the zone lists in such a way that a user of the API can easily know/find out what zone #5 is?

Could you explain how that problem is different from finding out
what memblk #5 is ... I don't see the difference?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
