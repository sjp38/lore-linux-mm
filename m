Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: slablru for 2.5.32-mm1
Date: Sun, 8 Sep 2002 23:43:40 +0200
References: <Pine.LNX.4.44.0209052032410.30628-100000@loke.as.arizona.edu> <1031286298.940.37.camel@phantasy>
In-Reply-To: <1031286298.940.37.camel@phantasy>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17oGD4-0006lm-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>, Craig Kulesa <ckulesa@as.arizona.edu>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@zip.com.au>, Ed Tomlinson <tomlins@cam.org>
List-ID: <linux-mm.kvack.org>

- 		if (unlikely((condition)!=0)) BUG(); \
+ 		if (unlikely(condition)) BUG(); \

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
