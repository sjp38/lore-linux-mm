Date: Mon, 17 Mar 2008 05:02:13 -0500
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] [18/18] Implement hugepagesz= option for x86-64
Message-Id: <20080317050213.e2599a98.pj@sgi.com>
In-Reply-To: <20080317095955.GB12405@basil.nowhere.org>
References: <20080317258.659191058@firstfloor.org>
	<20080317015832.2E3DF1B41E0@basil.firstfloor.org>
	<20080317042939.051e76ff.pj@sgi.com>
	<20080317095955.GB12405@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Andi wrote:
> Yes, but that was already there before. I didn't change it.
> 
> I agree it should be fixed, but i would prefer to not mix 
> PPC specific patches into my patchkit

Ok - good plan.

Do you know offhand what would be the correct HW list for hugepages and
hugepagesz?

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
