Content-Type: text/plain;
  charset="iso-8859-1"
From: Badari Pulavarty <pbadari@us.ibm.com>
Subject: Re: Poor DBT-3 pgsql 8way numbers on recent 2.6 mm kernels
Date: Mon, 15 Mar 2004 09:16:01 -0800
References: <1079130684.2961.134.camel@localhost> <20040313134842.78695cc6.akpm@osdl.org> <1079369109.2961.181.camel@localhost>
In-Reply-To: <1079369109.2961.181.camel@localhost>
MIME-Version: 1.0
Content-Transfer-Encoding: 8BIT
Message-Id: <200403150916.01339.pbadari@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: maryedie@osdl.org, Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 15 March 2004 08:45 am, Mary Edie Meredith wrote:
> On Sat, 2004-03-13 at 13:48, Andrew Morton wrote:
> > badari <pbadari@us.ibm.com> wrote:
> > > Andrew,
> > >
> > > We don't see any degradation with -mm trees with DSS workloads.
>
> Is your database using direct I/O?  PostgreSQL does not and
> that could be the difference.  Also we are doing very little
> I/O during this part of the run--only at the beginning of
> the Throughput part until the database gets cached in the
> page cache.  The database size is very small compared to
> most DSS workloads.


We are using filesystem buffered IO for our DSS workload testing.
(no direct IO). But our workload is very IO intensive. So its possible
that we don't see the problem you are seeing with "cached" workload.

Thanks,
Badari
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
