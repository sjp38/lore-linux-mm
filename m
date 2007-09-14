Date: Fri, 14 Sep 2007 11:57:26 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/4] hugetlb: fix pool allocation with empty nodes
In-Reply-To: <Pine.LNX.4.64.0709141152250.17038@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0709141156510.17038@schroedinger.engr.sgi.com>
References: <20070906182134.GA7779@us.ibm.com> <20070906182430.GB7779@us.ibm.com>
 <Pine.LNX.4.64.0709141152250.17038@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: anton@samba.org, wli@holomorphy.com, agl@us.ibm.com, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Actually we may want to introduce a new nodemask N_HUGEPAGES or so? That 
could contain the nodemask determined at boot?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
