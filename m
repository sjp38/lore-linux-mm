Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7064C6B0038
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 04:04:25 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 17so64967508pfy.2
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 01:04:25 -0800 (PST)
Received: from osg.samsung.com (ec2-52-27-115-49.us-west-2.compute.amazonaws.com. [52.27.115.49])
        by mx.google.com with ESMTP id o5si1485821pgg.216.2016.12.15.01.04.23
        for <linux-mm@kvack.org>;
        Thu, 15 Dec 2016 01:04:23 -0800 (PST)
Subject: Re: [PATCH 5/8] linux: drop __bitwise__ everywhere
References: <1481778865-27667-1-git-send-email-mst@redhat.com>
 <1481778865-27667-6-git-send-email-mst@redhat.com>
From: Stefan Schmidt <stefan@osg.samsung.com>
Message-ID: <23f887c1-dd34-2304-f7a2-d104154316d8@osg.samsung.com>
Date: Thu, 15 Dec 2016 10:04:13 +0100
MIME-Version: 1.0
In-Reply-To: <1481778865-27667-6-git-send-email-mst@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Cc: Kukjin Kim <kgene@kernel.org>, Krzysztof Kozlowski <krzk@kernel.org>, Javier Martinez Canillas <javier@osg.samsung.com>, Russell King <linux@armlinux.org.uk>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Shaohua Li <shli@kernel.org>, Johannes Berg <johannes.berg@intel.com>, Emmanuel Grumbach <emmanuel.grumbach@intel.com>, Luca Coelho <luciano.coelho@intel.com>, Intel Linux Wireless <linuxwifi@intel.com>, Kalle Valo <kvalo@codeaurora.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.com>, Lee Duncan <lduncan@suse.com>, Chris Leech <cleech@redhat.com>, "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, "Nicholas A. Bellinger" <nab@linux-iscsi.org>, Jason Wang <jasowang@redhat.com>, Alexander Aring <aar@pengutronix.de>, "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org, linux-samsung-soc@vger.kernel.org, linux-raid@vger.kernel.org, netdev@vger.kernel.org, linux-wireless@vger.kernel.org, linux-mm@kvack.org, open-iscsi@googlegroups.com, linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-wpan@vger.kernel.org

Hello.

On 15/12/16 06:15, Michael S. Tsirkin wrote:
> __bitwise__ used to mean "yes, please enable sparse checks
> unconditionally", but now that we dropped __CHECK_ENDIAN__
> __bitwise is exactly the same.
> There aren't many users, replace it by __bitwise everywhere.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  arch/arm/plat-samsung/include/plat/gpio-cfg.h    | 2 +-
>  drivers/md/dm-cache-block-types.h                | 6 +++---
>  drivers/net/ethernet/sun/sunhme.h                | 2 +-
>  drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h | 4 ++--
>  include/linux/mmzone.h                           | 2 +-
>  include/linux/serial_core.h                      | 4 ++--
>  include/linux/types.h                            | 4 ++--
>  include/scsi/iscsi_proto.h                       | 2 +-
>  include/target/target_core_base.h                | 2 +-
>  include/uapi/linux/virtio_types.h                | 6 +++---
>  net/ieee802154/6lowpan/6lowpan_i.h               | 2 +-
>  net/mac80211/ieee80211_i.h                       | 4 ++--
>  12 files changed, 20 insertions(+), 20 deletions(-)
>
> diff --git a/arch/arm/plat-samsung/include/plat/gpio-cfg.h b/arch/arm/plat-samsung/include/plat/gpio-cfg.h
> index 21391fa..e55d1f5 100644
> --- a/arch/arm/plat-samsung/include/plat/gpio-cfg.h
> +++ b/arch/arm/plat-samsung/include/plat/gpio-cfg.h
> @@ -26,7 +26,7 @@
>
>  #include <linux/types.h>
>
> -typedef unsigned int __bitwise__ samsung_gpio_pull_t;
> +typedef unsigned int __bitwise samsung_gpio_pull_t;
>
>  /* forward declaration if gpio-core.h hasn't been included */
>  struct samsung_gpio_chip;
> diff --git a/drivers/md/dm-cache-block-types.h b/drivers/md/dm-cache-block-types.h
> index bed4ad4..389c9e8 100644
> --- a/drivers/md/dm-cache-block-types.h
> +++ b/drivers/md/dm-cache-block-types.h
> @@ -17,9 +17,9 @@
>   * discard bitset.
>   */
>
> -typedef dm_block_t __bitwise__ dm_oblock_t;
> -typedef uint32_t __bitwise__ dm_cblock_t;
> -typedef dm_block_t __bitwise__ dm_dblock_t;
> +typedef dm_block_t __bitwise dm_oblock_t;
> +typedef uint32_t __bitwise dm_cblock_t;
> +typedef dm_block_t __bitwise dm_dblock_t;
>
>  static inline dm_oblock_t to_oblock(dm_block_t b)
>  {
> diff --git a/drivers/net/ethernet/sun/sunhme.h b/drivers/net/ethernet/sun/sunhme.h
> index f430765..4a8d5b1 100644
> --- a/drivers/net/ethernet/sun/sunhme.h
> +++ b/drivers/net/ethernet/sun/sunhme.h
> @@ -302,7 +302,7 @@
>   * Always write the address first before setting the ownership
>   * bits to avoid races with the hardware scanning the ring.
>   */
> -typedef u32 __bitwise__ hme32;
> +typedef u32 __bitwise hme32;
>
>  struct happy_meal_rxd {
>  	hme32 rx_flags;
> diff --git a/drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h b/drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h
> index 1ad0ec1..84813b5 100644
> --- a/drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h
> +++ b/drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h
> @@ -228,7 +228,7 @@ enum iwl_ucode_tlv_flag {
>  	IWL_UCODE_TLV_FLAGS_BCAST_FILTERING	= BIT(29),
>  };
>
> -typedef unsigned int __bitwise__ iwl_ucode_tlv_api_t;
> +typedef unsigned int __bitwise iwl_ucode_tlv_api_t;
>
>  /**
>   * enum iwl_ucode_tlv_api - ucode api
> @@ -258,7 +258,7 @@ enum iwl_ucode_tlv_api {
>  #endif
>  };
>
> -typedef unsigned int __bitwise__ iwl_ucode_tlv_capa_t;
> +typedef unsigned int __bitwise iwl_ucode_tlv_capa_t;
>
>  /**
>   * enum iwl_ucode_tlv_capa - ucode capabilities
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 0f088f3..36d9896 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -246,7 +246,7 @@ struct lruvec {
>  #define ISOLATE_UNEVICTABLE	((__force isolate_mode_t)0x8)
>
>  /* LRU Isolation modes. */
> -typedef unsigned __bitwise__ isolate_mode_t;
> +typedef unsigned __bitwise isolate_mode_t;
>
>  enum zone_watermarks {
>  	WMARK_MIN,
> diff --git a/include/linux/serial_core.h b/include/linux/serial_core.h
> index 5d49488..5def8e8 100644
> --- a/include/linux/serial_core.h
> +++ b/include/linux/serial_core.h
> @@ -111,8 +111,8 @@ struct uart_icount {
>  	__u32	buf_overrun;
>  };
>
> -typedef unsigned int __bitwise__ upf_t;
> -typedef unsigned int __bitwise__ upstat_t;
> +typedef unsigned int __bitwise upf_t;
> +typedef unsigned int __bitwise upstat_t;
>
>  struct uart_port {
>  	spinlock_t		lock;			/* port lock */
> diff --git a/include/linux/types.h b/include/linux/types.h
> index baf7183..d501ad3 100644
> --- a/include/linux/types.h
> +++ b/include/linux/types.h
> @@ -154,8 +154,8 @@ typedef u64 dma_addr_t;
>  typedef u32 dma_addr_t;
>  #endif
>
> -typedef unsigned __bitwise__ gfp_t;
> -typedef unsigned __bitwise__ fmode_t;
> +typedef unsigned __bitwise gfp_t;
> +typedef unsigned __bitwise fmode_t;
>
>  #ifdef CONFIG_PHYS_ADDR_T_64BIT
>  typedef u64 phys_addr_t;
> diff --git a/include/scsi/iscsi_proto.h b/include/scsi/iscsi_proto.h
> index c1260d8..df156f1 100644
> --- a/include/scsi/iscsi_proto.h
> +++ b/include/scsi/iscsi_proto.h
> @@ -74,7 +74,7 @@ static inline int iscsi_sna_gte(u32 n1, u32 n2)
>  #define zero_data(p) {p[0]=0;p[1]=0;p[2]=0;}
>
>  /* initiator tags; opaque for target */
> -typedef uint32_t __bitwise__ itt_t;
> +typedef uint32_t __bitwise itt_t;
>  /* below makes sense only for initiator that created this tag */
>  #define build_itt(itt, age) ((__force itt_t)\
>  	((itt) | ((age) << ISCSI_AGE_SHIFT)))
> diff --git a/include/target/target_core_base.h b/include/target/target_core_base.h
> index c211900..0055828 100644
> --- a/include/target/target_core_base.h
> +++ b/include/target/target_core_base.h
> @@ -149,7 +149,7 @@ enum se_cmd_flags_table {
>   * Used by transport_send_check_condition_and_sense()
>   * to signal which ASC/ASCQ sense payload should be built.
>   */
> -typedef unsigned __bitwise__ sense_reason_t;
> +typedef unsigned __bitwise sense_reason_t;
>
>  enum tcm_sense_reason_table {
>  #define R(x)	(__force sense_reason_t )(x)
> diff --git a/include/uapi/linux/virtio_types.h b/include/uapi/linux/virtio_types.h
> index e845e8c..55c3b73 100644
> --- a/include/uapi/linux/virtio_types.h
> +++ b/include/uapi/linux/virtio_types.h
> @@ -39,8 +39,8 @@
>   * - __le{16,32,64} for standard-compliant virtio devices
>   */
>
> -typedef __u16 __bitwise__ __virtio16;
> -typedef __u32 __bitwise__ __virtio32;
> -typedef __u64 __bitwise__ __virtio64;
> +typedef __u16 __bitwise __virtio16;
> +typedef __u32 __bitwise __virtio32;
> +typedef __u64 __bitwise __virtio64;
>
>  #endif /* _UAPI_LINUX_VIRTIO_TYPES_H */
> diff --git a/net/ieee802154/6lowpan/6lowpan_i.h b/net/ieee802154/6lowpan/6lowpan_i.h
> index 5ac7789..ac7c96b 100644
> --- a/net/ieee802154/6lowpan/6lowpan_i.h
> +++ b/net/ieee802154/6lowpan/6lowpan_i.h
> @@ -7,7 +7,7 @@
>  #include <net/inet_frag.h>
>  #include <net/6lowpan.h>
>
> -typedef unsigned __bitwise__ lowpan_rx_result;
> +typedef unsigned __bitwise lowpan_rx_result;
>  #define RX_CONTINUE		((__force lowpan_rx_result) 0u)
>  #define RX_DROP_UNUSABLE	((__force lowpan_rx_result) 1u)
>  #define RX_DROP			((__force lowpan_rx_result) 2u)
> diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
> index d37a577..b2069fb 100644
> --- a/net/mac80211/ieee80211_i.h
> +++ b/net/mac80211/ieee80211_i.h
> @@ -159,7 +159,7 @@ enum ieee80211_bss_valid_data_flags {
>  	IEEE80211_BSS_VALID_ERP			= BIT(3)
>  };
>
> -typedef unsigned __bitwise__ ieee80211_tx_result;
> +typedef unsigned __bitwise ieee80211_tx_result;
>  #define TX_CONTINUE	((__force ieee80211_tx_result) 0u)
>  #define TX_DROP		((__force ieee80211_tx_result) 1u)
>  #define TX_QUEUED	((__force ieee80211_tx_result) 2u)
> @@ -180,7 +180,7 @@ struct ieee80211_tx_data {
>  };
>
>
> -typedef unsigned __bitwise__ ieee80211_rx_result;
> +typedef unsigned __bitwise ieee80211_rx_result;
>  #define RX_CONTINUE		((__force ieee80211_rx_result) 0u)
>  #define RX_DROP_UNUSABLE	((__force ieee80211_rx_result) 1u)
>  #define RX_DROP_MONITOR		((__force ieee80211_rx_result) 2u)
>

For net/ieee802154/6lowpan/6lowpan_i.h

Acked-by: Stefan Schmidt <stefan@osg.samsung.com>

regards
Stefan Schmidt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
