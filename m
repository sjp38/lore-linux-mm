From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC] Net vm deadlock fix, version 6
Date: Fri, 12 Aug 2005 13:35:54 +1000
References: <200508120831.57884.phillips@istop.com>
In-Reply-To: <200508120831.57884.phillips@istop.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200508121335.54967.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: netdev@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

+	}
	adjust_memalloc_reserve(-netdev->memalloc_pages);
-	}

Regards,

Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
