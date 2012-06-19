Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 35BCF6B0068
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 15:49:39 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <c10bcaf9-aa56-4d6a-bc2c-310096b4198b@default>
Date: Tue, 19 Jun 2012 12:49:13 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 02/10] zcache: fix refcount leak
References: <4FE0392E.3090300@linux.vnet.ibm.com>
 <4FE03949.4080308@linux.vnet.ibm.com> <4FE08C9A.3010701@linux.vnet.ibm.com>
In-Reply-To: <4FE08C9A.3010701@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Konrad Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Sent: Tuesday, June 19, 2012 8:29 AM
> To: Xiao Guangrong
> Cc: Andrew Morton; Dan Magenheimer; LKML; linux-mm@kvack.org
> Subject: Re: [PATCH 02/10] zcache: fix refcount leak
>=20
> On 06/19/2012 03:33 AM, Xiao Guangrong wrote:
>=20
> > In zcache_get_pool_by_id, the refcount of zcache_host is not increased,=
 but
> > it is always decreased in zcache_put_pool
> >
> > Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
>=20
> Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

(Nitin Gupta and Konrad Wilk cc'ed to call their attention
to this patch sequence...)

My preference would be to fix it the opposite way, by
checking and ignoring zcache_host in zcache_put_pool.
The ref-counting is to ensure that a client isn't
accidentally destroyed while in use (for multiple-client
users such as ramster and kvm) and since zcache_host is a static
struct, it should never be deleted so need not be ref-counted.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
