Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [RFC] Page table sharing
Date: Fri, 22 Feb 2002 07:32:31 +0100
References: <Pine.LNX.4.33.0202181758260.24597-100000@home.transmeta.com> <E16e8Gf-0005HN-00@starship.berlin>
In-Reply-To: <E16e8Gf-0005HN-00@starship.berlin>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E16e9Fw-0005I3-00@starship.berlin>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>
Cc: Hugh Dickins <hugh@veritas.com>, dmccr@us.ibm.com, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Robert Love <rml@tech9.net>, mingo@redhat.com, Andrew Morton <akpm@zip.com.au>, manfred@colorfullife.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

The following gross mistake was noticed promptly by Rik van Riel:

	spin_lock(&page_table_share_lock);
-       if (page_count(virt_to_page(pte)) == 1) {
+	if (put_page_testzero(virt_to_page(pte))) {
		pmd_clear(dir);
		pte_free_slow(pte);
	}
	spin_unlock(&page_table_share_lock);

However, oddly enough, that's not the memory leak.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
