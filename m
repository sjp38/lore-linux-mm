Subject: Re: [PATCH 3/4] hugetlb: interleave dequeueing of huge pages
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0709141315510.22157@schroedinger.engr.sgi.com>
References: <20070906182134.GA7779@us.ibm.com>
	 <20070906182430.GB7779@us.ibm.com> <20070906182704.GC7779@us.ibm.com>
	 <Pine.LNX.4.64.0709141153360.17038@schroedinger.engr.sgi.com>
	 <1189796638.5315.50.camel@localhost>
	 <Pine.LNX.4.64.0709141241050.17369@schroedinger.engr.sgi.com>
	 <1189800591.5315.69.camel@localhost>
	 <Pine.LNX.4.64.0709141315510.22157@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 14 Sep 2007 16:33:00 -0400
Message-Id: <1189801980.5315.87.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, wli@holomorphy.com, agl@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2007-09-14 at 13:16 -0700, Christoph Lameter wrote:
> On Fri, 14 Sep 2007, Lee Schermerhorn wrote:
> 
> > Yeah, I mistyped...  But, nid IS private to that function.  This is a
> > valid use of static.  But, perhaps it could use a comment to call
> > attention to it.
> 
> I think its best to move nis outside of the function and give it a longer 
> name that is distinctive from names we use for local variables. F.e.
> 
> last_allocated_node
> 
> ?

I do like to see variables' [and functions'] visibility kept within the
minimum necessary scope, and moving it outside of the function violates
this.  Nothing else in the source file needs it.  But, If Nish agrees, I
guess I don't feel that strongly about it.  I like the suggested name,
tho'

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
