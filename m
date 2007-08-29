From: Oliver Neukum <oliver@neukum.org>
Subject: Re: speeding up swapoff
Date: Wed, 29 Aug 2007 16:36:46 +0200
References: <1188394172.22156.67.camel@localhost> <20070829073040.1ec35176@laptopd505.fenrus.org>
In-Reply-To: <20070829073040.1ec35176@laptopd505.fenrus.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200708291636.48323.oliver@neukum.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: Daniel Drake <ddrake@brontes3d.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Am Mittwoch 29 August 2007 schrieb Arjan van de Ven:
> Another question, if this is during system shutdown, maybe that's a
> valid case for flushing most of the pagecache first (from userspace)
> since most of what's there won't be used again anyway. If that's enough
> to make this go faster...

Is there a good reason to swapoff during shutdown?

	Regards
		Oliver

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
