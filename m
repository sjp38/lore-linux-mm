Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: 2.5.44-mm3: X doesn't work
Date: Wed, 23 Oct 2002 16:59:41 -0400
References: <20021023205808.0449836a.diegocg@teleline.es> <447940000.1035403802@flay>
In-Reply-To: <447940000.1035403802@flay>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200210231659.42064.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On October 23, 2002 04:10 pm, Martin J. Bligh wrote:
> CONFIG_SHAREPTE=y
> CONFIG_PREEMPT=y
>
> Want to try it again with the following?
> 1. CONFIG_SHPTE set, CONFIG_PREEMPT not set
> 2. CONFIG_SHPTE unset, CONFIG_PREEMPT set

Here with I see

1. CONFIG_SHPTE set, CONFIG_PREEMPT not - X startup fails starting ksmserver
2. CONFIG_SHPTE set, CONFIG_PREEMPT set - X startup fails starting ksmserver
3. CONFIG_SHPTE not, CONFIG_PREEMPT set - X works

I have not tried the fourth choise.  In my case X has never worked when SHPTE
is enabled - this has been true from the first versions of the patch.

Ed
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
