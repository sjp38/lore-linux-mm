Date: Fri, 21 Mar 2003 03:05:40 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.65-mm3
Message-Id: <20030321030540.598ebca5.akpm@digeo.com>
In-Reply-To: <87znnp3s1h.fsf@lapper.ihatent.com>
References: <20030320235821.1e4ff308.akpm@digeo.com>
	<87znnp3s1h.fsf@lapper.ihatent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Hoogerhuis <alexh@ihatent.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alexander Hoogerhuis <alexh@ihatent.com> wrote:
>
> Andrew Morton <akpm@digeo.com> writes:
> >
> > [SNIP]
> >
>
> ... 
> make[4]: *** [net/ipv4/netfilter/ip_conntrack_core.o] Error 1

Bah, sorry.

--- 25/net/ipv4/netfilter/ip_conntrack_core.c~a	2003-03-21 03:04:45.000000000 -0800
+++ 25-akpm/net/ipv4/netfilter/ip_conntrack_core.c	2003-03-21 03:04:48.000000000 -0800
@@ -274,7 +274,7 @@ static void remove_expectations(struct i
 		 * the un-established ones only */
 		if (exp->sibling) {
 			DEBUGP("remove_expectations: skipping established %p of %p\n", exp->sibling, ct);
-			exp->sibling =3D NULL;
+			exp->sibling = NULL;
 			continue;
 		}
 

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
