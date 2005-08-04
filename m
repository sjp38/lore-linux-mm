From: Daniel Phillips <phillips@istop.com>
Subject: Re: [RFC] Net vm deadlock fix (preliminary)
Date: Fri, 5 Aug 2005 08:09:22 +1000
References: <200508031657.34948.phillips@istop.com> <200508040606.07769.phillips@istop.com> <200508050751.34174.phillips@istop.com>
In-Reply-To: <200508050751.34174.phillips@istop.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200508050809.23271.phillips@istop.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Josefsson <gandalf@wlug.westbo.se>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-       return __dev_alloc_skb(length, gfp_mask | __GFP_MEMALLOC);
+       return __dev_alloc_skb(length, GFP_ATOMIC|__GFP_MEMALLOC);

Regards,

Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
