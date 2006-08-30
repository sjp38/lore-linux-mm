Date: Wed, 30 Aug 2006 14:04:40 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: libnuma interleaving oddness
In-Reply-To: <20060830072948.GE5195@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0608301401290.4217@schroedinger.engr.sgi.com>
References: <20060829231545.GY5195@us.ibm.com>
 <Pine.LNX.4.64.0608291655160.22397@schroedinger.engr.sgi.com>
 <20060830002110.GZ5195@us.ibm.com> <200608300919.13125.ak@suse.de>
 <20060830072948.GE5195@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Andi Kleen <ak@suse.de>, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, lnxninja@us.ibm.com, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

> I took out the mlock() call, and I get the same results, FWIW.

What zones are available on your box? Any with HIGHMEM?

Also what kernel version are we talking about? Before 2.6.18?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
