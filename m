Date: Tue, 12 Jun 2007 11:49:00 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
In-Reply-To: <20070612174326.GA3798@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706121147260.30754@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0706111745491.24389@schroedinger.engr.sgi.com>
 <20070612021245.GH3798@us.ibm.com> <Pine.LNX.4.64.0706111921370.25134@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0706111923580.25207@schroedinger.engr.sgi.com>
 <20070612023421.GL3798@us.ibm.com> <Pine.LNX.4.64.0706111954360.25390@schroedinger.engr.sgi.com>
 <20070612031718.GP3798@us.ibm.com> <Pine.LNX.4.64.0706112018260.25631@schroedinger.engr.sgi.com>
 <20070612033050.GR3798@us.ibm.com> <Pine.LNX.4.64.0706112046380.25900@schroedinger.engr.sgi.com>
 <20070612174326.GA3798@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jun 2007, Nishanth Aravamudan wrote:

> Ok, I see that. And it represent the next node to use for an interleaved
> allocation. Makes sense to me, and I see how it's used in mempolicy.c to
> achieve that. But we're running at system boot time, or whenever some

At boot time the init_task is running and you can effectively use a global
variable like you have now.

> invokes the sysctl /proc/sys/vm/nr_hugepages. Do we really want to muck
> with some arbitray bash shell's il_next field to achieve interleaving?
> What if it's a C process that is trying to achieve actual interleaving
> for other purposes and also allocates some hugepages on the system? It
> seems like il_next is very much a process-related field.

il_next is process related. Mucking around is what is was put there for.
The bash process wont be hurt by changing its il_next field.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
