From: Andi Kleen <ak@suse.de>
Subject: Re: libnuma interleaving oddness
Date: Thu, 31 Aug 2006 09:47:30 +0200
References: <20060829231545.GY5195@us.ibm.com> <Pine.LNX.4.64.0608301401290.4217@schroedinger.engr.sgi.com> <20060831060036.GA18661@us.ibm.com>
In-Reply-To: <20060831060036.GA18661@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200608310947.30542.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, lnxninja@us.ibm.com, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thursday 31 August 2006 08:00, Nishanth Aravamudan wrote:
> On 30.08.2006 [14:04:40 -0700], Christoph Lameter wrote:
> > > I took out the mlock() call, and I get the same results, FWIW.
> > 
> > What zones are available on your box? Any with HIGHMEM?
> 
> How do I tell the available zones from userspace? This is ppc64 with
> about 64GB of memory total, it looks like. So, none of the nodes
> (according to /sys/devices/system/node/*/meminfo) have highmem.

The zones are listed at the beginning of dmesg

"On node X total pages ...
      DMA zone ...
      ..." 

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
