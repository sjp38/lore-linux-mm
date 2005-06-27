Date: Mon, 27 Jun 2005 12:22:45 -0700 (PDT)
From: Christoph Lameter <christoph@lameter.com>
Subject: RE: [rfc] lockless pagecache
In-Reply-To: <200506271905.j5RJ5ag22991@unix-os.sc.intel.com>
Message-ID: <Pine.LNX.4.62.0506271221540.21616@graphe.net>
References: <200506271905.j5RJ5ag22991@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Badari Pulavarty' <pbadari@us.ibm.com>, 'Nick Piggin' <nickpiggin@yahoo.com.au>, Lincoln Dale <ltd@cisco.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 27 Jun 2005, Chen, Kenneth W wrote:

> I don't recall seeing tree_lock to be a problem for DSS workload either.

I have seen the tree_lock being a problem a number of times with large 
scale NUMA type workloads.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
