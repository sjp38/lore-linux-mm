Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [PATCH] Optimize away pte_chains for single mappings
Date: Mon, 15 Jul 2002 18:30:43 +0200
References: <55160000.1026239746@baldur.austin.ibm.com> <E17U7Gr-0003bX-00@starship> <20020715184016.W28720@mea-ext.zmailer.org>
In-Reply-To: <20020715184016.W28720@mea-ext.zmailer.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17U8kG-0003bx-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matti Aarnio <matti.aarnio@zmailer.org>
Cc: Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Monday 15 July 2002 17:40, Matti Aarnio wrote:
> In register-lacking i386 this  masking is definite punishment..

Nonsense, the value needs to be loaded into a register anyway
before being used.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
