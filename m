Received: from gateway.sf.frob.com ([64.81.54.130])
          (envelope-sender <roland@redhat.com>)
          by mail27.sea5.speakeasy.net (qmail-ldap-1.03) with SMTP
          for <linux-mm@kvack.org>; 1 Aug 2005 03:23:00 -0000
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
From: Roland McGrath <roland@redhat.com>
Subject: Re: get_user_pages() with write=1 and force=1 gets read-only pages.
In-Reply-To: Nick Piggin's message of  Monday, 1 August 2005 08:27:06 +1000 <42ED503A.6060101@yahoo.com.au>
Message-Id: <20050801032258.A465C180EC0@magilla.sf.frob.com>
Date: Sun, 31 Jul 2005 20:22:58 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The basic style of this fix seems appropriate to me.  I really don't think
it matters if get_user_pages does extra iterations of the lookup or fault
path in the race situations.  The unnecessary ones will always be short anyway.


Thanks,
Roland
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
