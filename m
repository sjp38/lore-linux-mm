Message-ID: <48EE1736.9090708@yandex.ru>
Date: Thu, 09 Oct 2008 17:37:42 +0300
From: Artem Bityutskiy <dedekind@yandex.ru>
MIME-Version: 1.0
Subject: Re: [patch 6/8] mm: write_cache_pages cleanups
References: <20081009155039.139856823@suse.de> <20081009174822.740252331@suse.de>
In-Reply-To: <20081009174822.740252331@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: Andrew Morton <akpm@linux-foundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

npiggin@suse.de wrote:
 > +			/*
> +			 * Page truncated or invalidated. We can freely skip it
> +			 * then, even for data integrity operations: the page
> +			 * has disappeared concurrently, so there could be no
> +			 * real expectation of this data interity operation

Apologies for nit-picking, but s/interity/integrity/

-- 
Best Regards,
Artem Bityutskiy (D?N?N?N?D 1/4  D?D,N?N?N?DoD,D1)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
