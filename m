Subject: Re: [ckrm-tech] [PATCH 3/3][RFC] Containers: Pagecache controller
	reclaim
From: Shane <ibm-main@tpg.com.au>
In-Reply-To: <20070305145311.247699000@linux.vnet.ibm.com>>
References: <20070305145237.003560000@linux.vnet.ibm.com> >
	  <20070305145311.247699000@linux.vnet.ibm.com>>
Content-Type: text/plain
Date: Tue, 06 Mar 2007 20:50:11 +1000
Message-Id: <1173178212.4998.54.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, vatsa@in.ibm.com, ckrm-tech@lists.sourceforge.net, balbir@in.ibm.com, xemul@sw.ru, menage@google.com, devel@openvz.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Anyone else have trouble fitting this patch ???.
I see a later version today, but not markedly different from this
mornings (Aus time). Initially I thought I had the first version, prior
to Balbir's RSS controller V2 re-write, but apparently not.
Kernel 2.6.20.1

Had to toss it away so I could do some base line testing - I'll redo the
build and see where the mis-matches are.

Shane ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
