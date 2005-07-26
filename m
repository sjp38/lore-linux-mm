Date: Tue, 26 Jul 2005 14:33:25 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: Memory pressure handling with iSCSI
Message-ID: <148380000.1122413605@flay>
In-Reply-To: <1122411949.6433.50.camel@dyn9047017102.beaverton.ibm.com>
References: <1122399331.6433.29.camel@dyn9047017102.beaverton.ibm.com> <Pine.LNX.4.61.0507261659250.1786@chimarrao.boston.redhat.com> <1122411949.6433.50.camel@dyn9047017102.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>, Rik van Riel <riel@redhat.com>, agl@us.ibm.com
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

>> > After KS & OLS discussions about memory pressure, I wanted to re-do
>> > iSCSI testing with "dd"s to see if we are throttling writes.  
>> 
>> Could you also try with shared writable mmap, to see if that
>> works ok or triggers a deadlock ?
> 
> 
> I can, but lets finish addressing one issue at a time. Last time,
> I changed too many things at the same time and got no where :(

Adam is working that one, but not over iSCSI.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
