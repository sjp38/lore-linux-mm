Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 986FB6B016A
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 02:53:51 -0400 (EDT)
Message-Id: <4E5365E80200007800052AD2@nat28.tlf.novell.com>
Date: Tue, 23 Aug 2011 07:33:44 +0100
From: "Jan Beulich" <JBeulich@novell.com>
Subject: RE: Subject: [PATCH V6 1/4] mm: frontswap: swap data structure
	 changes
References: <20110808204555.GA15850@ca-server1.us.oracle.com>
 <4E414320020000780005057E@nat28.tlf.novell.com><4E414320020000780005057E@nat28.tlf.novell.com>
 <ce8cba73-ec3c-42ae-849a-11db1df8ffa3@default
 4E4179D90200007800050676@nat28.tlf.novell.com><4E4179D90200007800050676@nat28.tlf.novell.com>
 <cf3e6497-c77f-47eb-a35e-360ea68ade85@default>
In-Reply-To: <cf3e6497-c77f-47eb-a35e-360ea68ade85@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: hannes@cmpxchg.org, jackdachef@gmail.com, hughd@google.com, jeremy@goop.org, npiggin@kernel.dk, linux-mm@kvack.org, akpm@linux-foundation.org, sjenning@linux.vnet.ibm.com, Chris Mason <chris.mason@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, Kurt Hackel <kurt.hackel@oracle.com>, riel@redhat.com, ngupta@vflare.org, linux-kernel@vger.kernel.org, matthew@wil.cx

>>> On 22.08.11 at 19:08, Dan Magenheimer <dan.magenheimer@oracle.com> =
wrote:
> With two extra static inlines in frontswap.h (frontswap_map_get()
> and frontswap_map_set(), I've managed to both avoid the extra swap =
struct
> members for frontswap_map and frontswap_pages when CONFIG_FRONTSWAP is
> disabled AND avoid the #ifdef CONFIG_FRONTSWAP clutter in swapfile.h.
>=20
> I'll post a V7 soon... let me know what you think!

Sounds promising - looking forward to seeing it.

Jan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
