Date: Thu, 01 Aug 2002 18:09:50 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: large page patch
Message-ID: <737220000.1028250590@flay>
In-Reply-To: <3D49D45A.D68CCFB4@zip.com.au>
References: <3D49D45A.D68CCFB4@zip.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "Seth, Rohit" <rohit.seth@intel.com>, "Saxena, Sunil" <sunil.saxena@intel.com>, "Mallick, Asit K" <asit.k.mallick@intel.com>
List-ID: <linux-mm.kvack.org>

> - The change to MAX_ORDER is unneeded

It's not only unneeded, it's detrimental. Not only will we spend more
time merging stuff up and down to no effect, it also makes the 
config_nonlinear stuff harder (or we have to #ifdef it, which just causes
more unnecessary differentiation). Please don't do that little bit ....

M.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
