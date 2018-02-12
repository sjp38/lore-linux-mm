Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D01E66B0027
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 09:38:42 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id c18so1164541pgv.8
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 06:38:42 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id k1-v6si3840138pld.10.2018.02.12.06.38.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Feb 2018 06:38:41 -0800 (PST)
From: "Li, Philip" <philip.li@intel.com>
Subject: RE: [kbuild-all] [nf:master 1/9] arch/x86/tools/insn_decoder_test:
 warning: ffffffff817c07c3:	0f ff e9 ud0 %ecx, %ebp
Date: Mon, 12 Feb 2018 14:38:37 +0000
Message-ID: <831EE4E5E37DCC428EB295A351E662494C9BD796@shsmsx102.ccr.corp.intel.com>
References: <201802071027.gHIvqB29%fengguang.wu@intel.com>
 <20180212133547.GD3443@dhcp22.suse.cz>
In-Reply-To: <20180212133547.GD3443@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, "Wu, Fengguang" <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, "coreteam@netfilter.org" <coreteam@netfilter.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "kbuild-all@01.org" <kbuild-all@01.org>, Andrew Morton <akpm@linux-foundation.org>, Pablo Neira Ayuso <pablo@netfilter.org>

> On Wed 07-02-18 10:16:31, Wu Fengguang wrote:
> > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git ma=
ster
> > head:   b408c5b04f82fe4e20bceb8e4f219453d4f21f02
> > commit: 0537250fdc6c876ed4cbbe874c739aebef493ee2 [1/9] netfilter: x_tab=
les:
> make allocation less aggressive
> > config: x86_64-rhel-7.2 (attached as .config)
> > compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
> > reproduce:
> >         git checkout 0537250fdc6c876ed4cbbe874c739aebef493ee2
> >         # save the attached .config to linux build tree
> >         make ARCH=3Dx86_64
> >
> > All warnings (new ones prefixed by >>):
> >
> >    arch/x86/tools/insn_decoder_test: warning: Found an x86 instruction =
decoder
> bug, please report this.
> >    arch/x86/tools/insn_decoder_test: warning: ffffffff817aed81:	0f ff c=
3
> 	ud0    %ebx,%eax
>=20
> I really fail to see how the above patch could have made any difference.
> I am even not sure what the actual bug is, to be honest.
sorry for the noise, this is a false positive after we upgrade to gcc7.3. W=
e have
blacklisted this warning in test farm, and kernel side has started the fix =
to handle
this. Kindly ignore this report.

>=20
> --
> Michal Hocko
> SUSE Labs
> _______________________________________________
> kbuild-all mailing list
> kbuild-all@lists.01.org
> https://lists.01.org/mailman/listinfo/kbuild-all

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
