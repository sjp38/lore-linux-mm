Date: Mon, 17 Mar 2008 03:09:42 -0500
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] [4/18] Add basic support for more than one hstate in
 hugetlbfs
Message-Id: <20080317030942.8465b09e.pj@sgi.com>
In-Reply-To: <20080317015817.DE00E1B41E0@basil.firstfloor.org>
References: <20080317258.659191058@firstfloor.org>
	<20080317015817.DE00E1B41E0@basil.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Andi,

Seems to me that both patches 2/18 and 4/18 are called:

  Add basic support for more than one hstate in hugetlbfs

You probably want to change this detail.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
