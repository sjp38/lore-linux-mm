Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 28E846B005A
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 10:23:42 -0400 (EDT)
Message-ID: <1344263015.27828.58.camel@twins>
Subject: Re: [PATCH v2 2/9] rbtree: optimize fetching of sibling node
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 06 Aug 2012 16:23:35 +0200
In-Reply-To: <1343946858-8170-3-git-send-email-walken@google.com>
References: <1343946858-8170-1-git-send-email-walken@google.com>
	 <1343946858-8170-3-git-send-email-walken@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: riel@redhat.com, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Thu, 2012-08-02 at 15:34 -0700, Michel Lespinasse wrote:

> +		tmp =3D gparent->rb_right;
> +		if (parent !=3D tmp) {	/* parent =3D=3D gparent->rb_left */

> +			tmp =3D parent->rb_right;
> +			if (node =3D=3D tmp) {

> +			tmp =3D parent->rb_left;
> +			if (node =3D=3D tmp) {

> +		sibling =3D parent->rb_right;
> +		if (node !=3D sibling) {	/* node =3D=3D parent->rb_left */


Half of them got a comment, the other half didn't.. is there any
particular reason for that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
