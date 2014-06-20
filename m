Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 224DB6B0035
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 23:51:50 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id w10so2516689pde.10
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 20:51:49 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id bw4si8044716pbd.160.2014.06.19.20.51.48
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 20:51:49 -0700 (PDT)
Date: Fri, 20 Jun 2014 11:51:29 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 188/230] crypto/zlib.c:171:2: warning: format '%u'
 expects argument of type 'unsigned int', but argument 3 has type 'uLong'
Message-ID: <53a3afc1.QvpKlMfidnG3/9cK%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   df25ba7db0775d87018e2cd92f26b9b087093840
commit: 0b3f61ac78013e35939696ddd63b9b871d11bf72 [188/230] initramfs: support initramfs that is more than 2G
config: make ARCH=i386 allyesconfig

All warnings:

   crypto/zlib.c: In function 'zlib_compress_update':
>> crypto/zlib.c:171:2: warning: format '%u' expects argument of type 'unsigned int', but argument 3 has type 'uLong' [-Wformat=]
     pr_debug("avail_in %u, avail_out %u (consumed %u, produced %u)\n",
     ^
>> crypto/zlib.c:171:2: warning: format '%u' expects argument of type 'unsigned int', but argument 4 has type 'uLong' [-Wformat=]
>> crypto/zlib.c:171:2: warning: format '%u' expects argument of type 'unsigned int', but argument 5 has type 'long unsigned int' [-Wformat=]
   crypto/zlib.c: In function 'zlib_compress_final':
>> crypto/zlib.c:201:2: warning: format '%u' expects argument of type 'unsigned int', but argument 3 has type 'uLong' [-Wformat=]
     pr_debug("avail_in %u, avail_out %u (consumed %u, produced %u)\n",
     ^
>> crypto/zlib.c:201:2: warning: format '%u' expects argument of type 'unsigned int', but argument 4 has type 'uLong' [-Wformat=]
>> crypto/zlib.c:201:2: warning: format '%u' expects argument of type 'unsigned int', but argument 5 has type 'long unsigned int' [-Wformat=]
   crypto/zlib.c: In function 'zlib_decompress_update':
>> crypto/zlib.c:286:2: warning: format '%u' expects argument of type 'unsigned int', but argument 3 has type 'uLong' [-Wformat=]
     pr_debug("avail_in %u, avail_out %u (consumed %u, produced %u)\n",
     ^
>> crypto/zlib.c:286:2: warning: format '%u' expects argument of type 'unsigned int', but argument 4 has type 'uLong' [-Wformat=]
>> crypto/zlib.c:286:2: warning: format '%u' expects argument of type 'unsigned int', but argument 5 has type 'long unsigned int' [-Wformat=]
   crypto/zlib.c: In function 'zlib_decompress_final':
>> crypto/zlib.c:334:2: warning: format '%u' expects argument of type 'unsigned int', but argument 3 has type 'uLong' [-Wformat=]
     pr_debug("avail_in %u, avail_out %u (consumed %u, produced %u)\n",
     ^
>> crypto/zlib.c:334:2: warning: format '%u' expects argument of type 'unsigned int', but argument 4 has type 'uLong' [-Wformat=]
>> crypto/zlib.c:334:2: warning: format '%u' expects argument of type 'unsigned int', but argument 5 has type 'long unsigned int' [-Wformat=]
--
   fs/jffs2/compr_zlib.c: In function 'jffs2_zlib_compress':
>> fs/jffs2/compr_zlib.c:97:199: warning: comparison of distinct pointer types lacks a cast [enabled by default]
      def_strm.avail_in = min((unsigned)(*sourcelen-def_strm.total_in), def_strm.avail_out);
                                                                                                                                                                                                          ^
>> fs/jffs2/compr_zlib.c:98:3: warning: format '%d' expects argument of type 'int', but argument 2 has type 'uLong' [-Wformat=]
      jffs2_dbg(1, "calling deflate with avail_in %d, avail_out %d\n",
      ^
>> fs/jffs2/compr_zlib.c:98:3: warning: format '%d' expects argument of type 'int', but argument 3 has type 'uLong' [-Wformat=]
>> fs/jffs2/compr_zlib.c:101:3: warning: format '%d' expects argument of type 'int', but argument 2 has type 'uLong' [-Wformat=]
      jffs2_dbg(1, "deflate returned with avail_in %d, avail_out %d, total_in %ld, total_out %ld\n",
      ^
>> fs/jffs2/compr_zlib.c:101:3: warning: format '%d' expects argument of type 'int', but argument 3 has type 'uLong' [-Wformat=]

vim +171 crypto/zlib.c

bf68e65e Geert Uytterhoeven 2009-03-04  165  	default:
bf68e65e Geert Uytterhoeven 2009-03-04  166  		pr_debug("zlib_deflate failed %d\n", ret);
bf68e65e Geert Uytterhoeven 2009-03-04  167  		return -EINVAL;
bf68e65e Geert Uytterhoeven 2009-03-04  168  	}
bf68e65e Geert Uytterhoeven 2009-03-04  169  
3ce858cb Geert Uytterhoeven 2009-05-27  170  	ret = req->avail_out - stream->avail_out;
bf68e65e Geert Uytterhoeven 2009-03-04 @171  	pr_debug("avail_in %u, avail_out %u (consumed %u, produced %u)\n",
bf68e65e Geert Uytterhoeven 2009-03-04  172  		 stream->avail_in, stream->avail_out,
3ce858cb Geert Uytterhoeven 2009-05-27  173  		 req->avail_in - stream->avail_in, ret);
bf68e65e Geert Uytterhoeven 2009-03-04  174  	req->next_in = stream->next_in;
bf68e65e Geert Uytterhoeven 2009-03-04  175  	req->avail_in = stream->avail_in;
bf68e65e Geert Uytterhoeven 2009-03-04  176  	req->next_out = stream->next_out;
bf68e65e Geert Uytterhoeven 2009-03-04  177  	req->avail_out = stream->avail_out;
3ce858cb Geert Uytterhoeven 2009-05-27  178  	return ret;
bf68e65e Geert Uytterhoeven 2009-03-04  179  }
bf68e65e Geert Uytterhoeven 2009-03-04  180  
bf68e65e Geert Uytterhoeven 2009-03-04  181  static int zlib_compress_final(struct crypto_pcomp *tfm,
bf68e65e Geert Uytterhoeven 2009-03-04  182  			       struct comp_request *req)
bf68e65e Geert Uytterhoeven 2009-03-04  183  {
bf68e65e Geert Uytterhoeven 2009-03-04  184  	int ret;
bf68e65e Geert Uytterhoeven 2009-03-04  185  	struct zlib_ctx *dctx = crypto_tfm_ctx(crypto_pcomp_tfm(tfm));
bf68e65e Geert Uytterhoeven 2009-03-04  186  	struct z_stream_s *stream = &dctx->comp_stream;
bf68e65e Geert Uytterhoeven 2009-03-04  187  
bf68e65e Geert Uytterhoeven 2009-03-04  188  	pr_debug("avail_in %u, avail_out %u\n", req->avail_in, req->avail_out);
bf68e65e Geert Uytterhoeven 2009-03-04  189  	stream->next_in = req->next_in;
bf68e65e Geert Uytterhoeven 2009-03-04  190  	stream->avail_in = req->avail_in;
bf68e65e Geert Uytterhoeven 2009-03-04  191  	stream->next_out = req->next_out;
bf68e65e Geert Uytterhoeven 2009-03-04  192  	stream->avail_out = req->avail_out;
bf68e65e Geert Uytterhoeven 2009-03-04  193  
bf68e65e Geert Uytterhoeven 2009-03-04  194  	ret = zlib_deflate(stream, Z_FINISH);
bf68e65e Geert Uytterhoeven 2009-03-04  195  	if (ret != Z_STREAM_END) {
bf68e65e Geert Uytterhoeven 2009-03-04  196  		pr_debug("zlib_deflate failed %d\n", ret);
bf68e65e Geert Uytterhoeven 2009-03-04  197  		return -EINVAL;
bf68e65e Geert Uytterhoeven 2009-03-04  198  	}
bf68e65e Geert Uytterhoeven 2009-03-04  199  
3ce858cb Geert Uytterhoeven 2009-05-27  200  	ret = req->avail_out - stream->avail_out;
bf68e65e Geert Uytterhoeven 2009-03-04 @201  	pr_debug("avail_in %u, avail_out %u (consumed %u, produced %u)\n",
bf68e65e Geert Uytterhoeven 2009-03-04  202  		 stream->avail_in, stream->avail_out,
3ce858cb Geert Uytterhoeven 2009-05-27  203  		 req->avail_in - stream->avail_in, ret);
bf68e65e Geert Uytterhoeven 2009-03-04  204  	req->next_in = stream->next_in;
bf68e65e Geert Uytterhoeven 2009-03-04  205  	req->avail_in = stream->avail_in;
bf68e65e Geert Uytterhoeven 2009-03-04  206  	req->next_out = stream->next_out;
bf68e65e Geert Uytterhoeven 2009-03-04  207  	req->avail_out = stream->avail_out;
3ce858cb Geert Uytterhoeven 2009-05-27  208  	return ret;
bf68e65e Geert Uytterhoeven 2009-03-04  209  }
bf68e65e Geert Uytterhoeven 2009-03-04  210  
bf68e65e Geert Uytterhoeven 2009-03-04  211  
bf68e65e Geert Uytterhoeven 2009-03-04  212  static int zlib_decompress_setup(struct crypto_pcomp *tfm, void *params,
bf68e65e Geert Uytterhoeven 2009-03-04  213  				 unsigned int len)
bf68e65e Geert Uytterhoeven 2009-03-04  214  {
bf68e65e Geert Uytterhoeven 2009-03-04  215  	struct zlib_ctx *ctx = crypto_tfm_ctx(crypto_pcomp_tfm(tfm));
bf68e65e Geert Uytterhoeven 2009-03-04  216  	struct z_stream_s *stream = &ctx->decomp_stream;
bf68e65e Geert Uytterhoeven 2009-03-04  217  	struct nlattr *tb[ZLIB_DECOMP_MAX + 1];
bf68e65e Geert Uytterhoeven 2009-03-04  218  	int ret = 0;
bf68e65e Geert Uytterhoeven 2009-03-04  219  
bf68e65e Geert Uytterhoeven 2009-03-04  220  	ret = nla_parse(tb, ZLIB_DECOMP_MAX, params, len, NULL);
bf68e65e Geert Uytterhoeven 2009-03-04  221  	if (ret)
bf68e65e Geert Uytterhoeven 2009-03-04  222  		return ret;
bf68e65e Geert Uytterhoeven 2009-03-04  223  
bf68e65e Geert Uytterhoeven 2009-03-04  224  	zlib_decomp_exit(ctx);
bf68e65e Geert Uytterhoeven 2009-03-04  225  
bf68e65e Geert Uytterhoeven 2009-03-04  226  	ctx->decomp_windowBits = tb[ZLIB_DECOMP_WINDOWBITS]
bf68e65e Geert Uytterhoeven 2009-03-04  227  				 ? nla_get_u32(tb[ZLIB_DECOMP_WINDOWBITS])
bf68e65e Geert Uytterhoeven 2009-03-04  228  				 : DEF_WBITS;
bf68e65e Geert Uytterhoeven 2009-03-04  229  
7ab24bfd David S. Miller    2011-06-29  230  	stream->workspace = vzalloc(zlib_inflate_workspacesize());
bf68e65e Geert Uytterhoeven 2009-03-04  231  	if (!stream->workspace)
bf68e65e Geert Uytterhoeven 2009-03-04  232  		return -ENOMEM;
bf68e65e Geert Uytterhoeven 2009-03-04  233  
bf68e65e Geert Uytterhoeven 2009-03-04  234  	ret = zlib_inflateInit2(stream, ctx->decomp_windowBits);
bf68e65e Geert Uytterhoeven 2009-03-04  235  	if (ret != Z_OK) {
7ab24bfd David S. Miller    2011-06-29  236  		vfree(stream->workspace);
bf68e65e Geert Uytterhoeven 2009-03-04  237  		stream->workspace = NULL;
bf68e65e Geert Uytterhoeven 2009-03-04  238  		return -EINVAL;
bf68e65e Geert Uytterhoeven 2009-03-04  239  	}
bf68e65e Geert Uytterhoeven 2009-03-04  240  
bf68e65e Geert Uytterhoeven 2009-03-04  241  	return 0;
bf68e65e Geert Uytterhoeven 2009-03-04  242  }
bf68e65e Geert Uytterhoeven 2009-03-04  243  
bf68e65e Geert Uytterhoeven 2009-03-04  244  static int zlib_decompress_init(struct crypto_pcomp *tfm)
bf68e65e Geert Uytterhoeven 2009-03-04  245  {
bf68e65e Geert Uytterhoeven 2009-03-04  246  	int ret;
bf68e65e Geert Uytterhoeven 2009-03-04  247  	struct zlib_ctx *dctx = crypto_tfm_ctx(crypto_pcomp_tfm(tfm));
bf68e65e Geert Uytterhoeven 2009-03-04  248  	struct z_stream_s *stream = &dctx->decomp_stream;
bf68e65e Geert Uytterhoeven 2009-03-04  249  
bf68e65e Geert Uytterhoeven 2009-03-04  250  	ret = zlib_inflateReset(stream);
bf68e65e Geert Uytterhoeven 2009-03-04  251  	if (ret != Z_OK)
bf68e65e Geert Uytterhoeven 2009-03-04  252  		return -EINVAL;
bf68e65e Geert Uytterhoeven 2009-03-04  253  
bf68e65e Geert Uytterhoeven 2009-03-04  254  	return 0;
bf68e65e Geert Uytterhoeven 2009-03-04  255  }
bf68e65e Geert Uytterhoeven 2009-03-04  256  
bf68e65e Geert Uytterhoeven 2009-03-04  257  static int zlib_decompress_update(struct crypto_pcomp *tfm,
bf68e65e Geert Uytterhoeven 2009-03-04  258  				  struct comp_request *req)
bf68e65e Geert Uytterhoeven 2009-03-04  259  {
bf68e65e Geert Uytterhoeven 2009-03-04  260  	int ret;
bf68e65e Geert Uytterhoeven 2009-03-04  261  	struct zlib_ctx *dctx = crypto_tfm_ctx(crypto_pcomp_tfm(tfm));
bf68e65e Geert Uytterhoeven 2009-03-04  262  	struct z_stream_s *stream = &dctx->decomp_stream;
bf68e65e Geert Uytterhoeven 2009-03-04  263  
bf68e65e Geert Uytterhoeven 2009-03-04  264  	pr_debug("avail_in %u, avail_out %u\n", req->avail_in, req->avail_out);
bf68e65e Geert Uytterhoeven 2009-03-04  265  	stream->next_in = req->next_in;
bf68e65e Geert Uytterhoeven 2009-03-04  266  	stream->avail_in = req->avail_in;
bf68e65e Geert Uytterhoeven 2009-03-04  267  	stream->next_out = req->next_out;
bf68e65e Geert Uytterhoeven 2009-03-04  268  	stream->avail_out = req->avail_out;
bf68e65e Geert Uytterhoeven 2009-03-04  269  
bf68e65e Geert Uytterhoeven 2009-03-04  270  	ret = zlib_inflate(stream, Z_SYNC_FLUSH);
bf68e65e Geert Uytterhoeven 2009-03-04  271  	switch (ret) {
bf68e65e Geert Uytterhoeven 2009-03-04  272  	case Z_OK:
bf68e65e Geert Uytterhoeven 2009-03-04  273  	case Z_STREAM_END:
bf68e65e Geert Uytterhoeven 2009-03-04  274  		break;
bf68e65e Geert Uytterhoeven 2009-03-04  275  
bf68e65e Geert Uytterhoeven 2009-03-04  276  	case Z_BUF_ERROR:
bf68e65e Geert Uytterhoeven 2009-03-04  277  		pr_debug("zlib_inflate could not make progress\n");
bf68e65e Geert Uytterhoeven 2009-03-04  278  		return -EAGAIN;
bf68e65e Geert Uytterhoeven 2009-03-04  279  
bf68e65e Geert Uytterhoeven 2009-03-04  280  	default:
bf68e65e Geert Uytterhoeven 2009-03-04  281  		pr_debug("zlib_inflate failed %d\n", ret);
bf68e65e Geert Uytterhoeven 2009-03-04  282  		return -EINVAL;
bf68e65e Geert Uytterhoeven 2009-03-04  283  	}
bf68e65e Geert Uytterhoeven 2009-03-04  284  
3ce858cb Geert Uytterhoeven 2009-05-27  285  	ret = req->avail_out - stream->avail_out;
bf68e65e Geert Uytterhoeven 2009-03-04 @286  	pr_debug("avail_in %u, avail_out %u (consumed %u, produced %u)\n",
bf68e65e Geert Uytterhoeven 2009-03-04  287  		 stream->avail_in, stream->avail_out,
3ce858cb Geert Uytterhoeven 2009-05-27  288  		 req->avail_in - stream->avail_in, ret);
bf68e65e Geert Uytterhoeven 2009-03-04  289  	req->next_in = stream->next_in;
bf68e65e Geert Uytterhoeven 2009-03-04  290  	req->avail_in = stream->avail_in;
bf68e65e Geert Uytterhoeven 2009-03-04  291  	req->next_out = stream->next_out;
bf68e65e Geert Uytterhoeven 2009-03-04  292  	req->avail_out = stream->avail_out;
3ce858cb Geert Uytterhoeven 2009-05-27  293  	return ret;
bf68e65e Geert Uytterhoeven 2009-03-04  294  }
bf68e65e Geert Uytterhoeven 2009-03-04  295  
bf68e65e Geert Uytterhoeven 2009-03-04  296  static int zlib_decompress_final(struct crypto_pcomp *tfm,
bf68e65e Geert Uytterhoeven 2009-03-04  297  				 struct comp_request *req)
bf68e65e Geert Uytterhoeven 2009-03-04  298  {
bf68e65e Geert Uytterhoeven 2009-03-04  299  	int ret;
bf68e65e Geert Uytterhoeven 2009-03-04  300  	struct zlib_ctx *dctx = crypto_tfm_ctx(crypto_pcomp_tfm(tfm));
bf68e65e Geert Uytterhoeven 2009-03-04  301  	struct z_stream_s *stream = &dctx->decomp_stream;
bf68e65e Geert Uytterhoeven 2009-03-04  302  
bf68e65e Geert Uytterhoeven 2009-03-04  303  	pr_debug("avail_in %u, avail_out %u\n", req->avail_in, req->avail_out);
bf68e65e Geert Uytterhoeven 2009-03-04  304  	stream->next_in = req->next_in;
bf68e65e Geert Uytterhoeven 2009-03-04  305  	stream->avail_in = req->avail_in;
bf68e65e Geert Uytterhoeven 2009-03-04  306  	stream->next_out = req->next_out;
bf68e65e Geert Uytterhoeven 2009-03-04  307  	stream->avail_out = req->avail_out;
bf68e65e Geert Uytterhoeven 2009-03-04  308  
bf68e65e Geert Uytterhoeven 2009-03-04  309  	if (dctx->decomp_windowBits < 0) {
bf68e65e Geert Uytterhoeven 2009-03-04  310  		ret = zlib_inflate(stream, Z_SYNC_FLUSH);
bf68e65e Geert Uytterhoeven 2009-03-04  311  		/*
bf68e65e Geert Uytterhoeven 2009-03-04  312  		 * Work around a bug in zlib, which sometimes wants to taste an
bf68e65e Geert Uytterhoeven 2009-03-04  313  		 * extra byte when being used in the (undocumented) raw deflate
bf68e65e Geert Uytterhoeven 2009-03-04  314  		 * mode. (From USAGI).
bf68e65e Geert Uytterhoeven 2009-03-04  315  		 */
bf68e65e Geert Uytterhoeven 2009-03-04  316  		if (ret == Z_OK && !stream->avail_in && stream->avail_out) {
bf68e65e Geert Uytterhoeven 2009-03-04  317  			const void *saved_next_in = stream->next_in;
bf68e65e Geert Uytterhoeven 2009-03-04  318  			u8 zerostuff = 0;
bf68e65e Geert Uytterhoeven 2009-03-04  319  
bf68e65e Geert Uytterhoeven 2009-03-04  320  			stream->next_in = &zerostuff;
bf68e65e Geert Uytterhoeven 2009-03-04  321  			stream->avail_in = 1;
bf68e65e Geert Uytterhoeven 2009-03-04  322  			ret = zlib_inflate(stream, Z_FINISH);
bf68e65e Geert Uytterhoeven 2009-03-04  323  			stream->next_in = saved_next_in;
bf68e65e Geert Uytterhoeven 2009-03-04  324  			stream->avail_in = 0;
bf68e65e Geert Uytterhoeven 2009-03-04  325  		}
bf68e65e Geert Uytterhoeven 2009-03-04  326  	} else
bf68e65e Geert Uytterhoeven 2009-03-04  327  		ret = zlib_inflate(stream, Z_FINISH);
bf68e65e Geert Uytterhoeven 2009-03-04  328  	if (ret != Z_STREAM_END) {
bf68e65e Geert Uytterhoeven 2009-03-04  329  		pr_debug("zlib_inflate failed %d\n", ret);
bf68e65e Geert Uytterhoeven 2009-03-04  330  		return -EINVAL;
bf68e65e Geert Uytterhoeven 2009-03-04  331  	}
bf68e65e Geert Uytterhoeven 2009-03-04  332  
3ce858cb Geert Uytterhoeven 2009-05-27  333  	ret = req->avail_out - stream->avail_out;
bf68e65e Geert Uytterhoeven 2009-03-04 @334  	pr_debug("avail_in %u, avail_out %u (consumed %u, produced %u)\n",
bf68e65e Geert Uytterhoeven 2009-03-04  335  		 stream->avail_in, stream->avail_out,
3ce858cb Geert Uytterhoeven 2009-05-27  336  		 req->avail_in - stream->avail_in, ret);
bf68e65e Geert Uytterhoeven 2009-03-04  337  	req->next_in = stream->next_in;

:::::: The code at line 171 was first introduced by commit
:::::: bf68e65ec9ea61e32ab71bef59aa5d24d255241f crypto: zlib - New zlib crypto module, using pcomp

:::::: TO: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
:::::: CC: Herbert Xu <herbert@gondor.apana.org.au>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
