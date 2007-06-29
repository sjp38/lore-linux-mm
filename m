From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH/RFC 0/11] Shared Policy Overview
Date: Fri, 29 Jun 2007 19:42:06 +0200
References: <20070625195224.21210.89898.sendpatchset@localhost> <200706290002.12113.ak@suse.de> <1183137257.5012.12.camel@localhost>
In-Reply-To: <1183137257.5012.12.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200706291942.06679.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, "Paul E. McKenney" <paulmck@us.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com
List-ID: <linux-mm.kvack.org>

> Andi:  I could restore the tail call for the common cases of system
> default and task policy, but that would require a second call to
> __alloc_pages(), I think, for the shared and vma policies.  What do you
> think about that solution?

Fine

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
